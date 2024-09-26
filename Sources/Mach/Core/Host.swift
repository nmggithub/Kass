import CCompat
import Darwin.Mach
import Foundation

extension Mach {
    /// A host.
    public class Host: Mach.Port {
        /// The current host.
        public static var current: Self { Self(named: mach_host_self()) }

        /// The boot info for the host.
        public var bootInfo: String {
            get throws {
                let bootInfoStr = UnsafeMutablePointer<CChar>.allocate(
                    capacity: Int(KERNEL_BOOT_INFO_MAX)
                )
                try Mach.call(host_get_boot_info(self.name, bootInfoStr))
                return String(cString: bootInfoStr)
            }
        }

        /// The kernel version for the host.
        public var kernelVersion: String {
            get throws {
                let kernelVersionStr = UnsafeMutablePointer<CChar>.allocate(
                    capacity: Int(512)
                )
                try Mach.call(host_kernel_version(self.name, kernelVersionStr))
                return String(cString: kernelVersionStr)
            }
        }

        /// The page size for the host.
        public var pageSize: vm_size_t {
            get throws {
                var pageSize: vm_size_t = 0
                try Mach.call(host_page_size(self.name, &pageSize))
                return pageSize
            }
        }

        /// A reboot option.
        public enum RebootOption: Int32 {
            case halt = 0x8
            case upsDelay = 0x100
            case debugger = 0x1000
        }
        /// Reboots the host.
        public func reboot(_ options: Set<RebootOption> = []) throws {
            try Mach.call(host_reboot(self.name, options.bitmap()))
        }
    }
}

extension Mach.Task {
    /// The host port for the host that the task is in.
    public var hostPort: Mach.Host {
        get throws { try getSpecialPort(.host) }
    }
}

extension Mach.Host {
    /// Performs a kext request.
    public func kextRequest(_ request: Data) throws -> Data {
        let dataCopy = request.withUnsafeBytes {
            buffer in
            let bufferCopy = UnsafeMutableRawBufferPointer.allocate(
                byteCount: buffer.count, alignment: 1
            )
            bufferCopy.copyMemory(from: buffer)
            return bufferCopy
        }
        defer { dataCopy.deallocate() }
        var responseAddress = vm_offset_t()
        var responseCount = mach_msg_size_t()
        var actualReturn = kern_return_t()
        try Mach.call(
            kext_request(
                self.name,
                0,
                vm_offset_t(bitPattern: dataCopy.baseAddress),
                mach_msg_size_t(request.count),
                &responseAddress, &responseCount,
                nil, nil, &actualReturn
            )
        )
        try Mach.call(actualReturn)
        let response = Data(
            bytes: UnsafeRawPointer(bitPattern: responseAddress)!,
            count: Int(responseCount)
        )
        return response
    }
}

extension Mach {
    /// A type of host info.
    public enum HostInfo: host_flavor_t {
        case basic = 1
        case scheduling = 3
        case resourceSizes = 4
        case priority = 5
        case semaphoreTraps = 7
        case machMsgTraps = 8
        case vmPurgeable = 9
        case debugInfo = 10
        /// - Note: Yes, this is what it's actually called.
        case canHasDebugger = 11
        case preferredUserspaceArchitecture = 12
    }

    /// A collection of host statistics.
    public enum HostStatistics: host_flavor_t {
        case load = 1
        case vm = 2
        case cpuLoad = 3
        case vm64 = 4
        case extMod = 5
        case expiredTasks = 6
    }
}

extension Mach.Host {
    /// Gets the value of host info.
    public func getInfo<DataType: BitwiseCopyable>(
        _ info: Mach.HostInfo, as type: DataType.Type
    ) throws -> DataType {
        try Mach.callWithCountInOut(type: type) {
            array, count in
            host_info(self.name, info.rawValue, array, &count)
        }
    }

    /// Gets the host's statistics.
    public func getStatistics<DataType: BitwiseCopyable>(
        _ collection: Mach.HostStatistics, as type: DataType.Type
    ) throws -> DataType {
        try Mach.callWithCountInOut(type: type) {
            array, count in
            switch collection {
            case .load, .vm, .cpuLoad, .expiredTasks:
                host_statistics(self.name, collection.rawValue, array, &count)
            case .vm64, .extMod:
                host_statistics64(self.name, collection.rawValue, array, &count)
            }
        }
    }
}

extension Mach.Host {
    /// A memory manager.
    public class MemoryManager: Mach.Port {}

    /// Gets the default memory manager for the host.
    public func getDefaultMemoryManager() throws -> MemoryManager {
        var name = mach_port_name_t()
        try Mach.call(
            host_default_memory_manager(self.name, &name, 0)
        )
        return MemoryManager(named: name)
    }

    /// Sets the default memory manager for the host.
    public func setDefaultMemoryManager(to manager: MemoryManager) throws {
        var name = manager.name
        try Mach.call(
            host_default_memory_manager(self.name, &name, 0)
        )
    }
}

extension Mach.Host {
    /// A lock group.
    public struct LockGroup: RawRepresentable {
        public var rawValue: lockgroup_info_t {
            var rawValue = lockgroup_info_t()
            var nameData = name.data(using: .utf8)!
            let remaining = Int(LOCKGROUP_MAX_NAME) - nameData.count
            if remaining > 0 { nameData += Data(repeating: 0, count: remaining) }
            let nameCString = String(
                data: nameData.prefix(Int(LOCKGROUP_MAX_NAME)),
                encoding: .utf8
            )!.cString(using: .utf8)!
            strncpy(&rawValue.lockgroup_name, nameCString, Int(LOCKGROUP_MAX_NAME))
            rawValue.lock_spin_cnt = spinCount
            rawValue.lock_mtx_cnt = mutexCount
            rawValue.lock_rw_cnt = rwCount

            rawValue.lock_spin_held_cnt = spinHeldCount
            rawValue.lock_spin_miss_cnt = spinMissCount
            rawValue.lock_mtx_util_cnt = mutexUtilCount
            rawValue.lock_mtx_held_cnt = mutexHeldCount
            rawValue.lock_mtx_miss_cnt = mutexMissCount
            rawValue.lock_mtx_wait_cnt = mutexWaitCount
            return rawValue
        }
        public init(rawValue: lockgroup_info_t) {
            self.name = withUnsafePointer(to: rawValue.lockgroup_name) {
                pointer in
                pointer.withMemoryRebound(to: CChar.self, capacity: Int(LOCKGROUP_MAX_NAME)) {
                    String(cString: $0)
                }
            }
            self.spinCount = rawValue.lock_spin_cnt
            self.mutexCount = rawValue.lock_mtx_cnt
            self.rwCount = rawValue.lock_rw_cnt

            self.spinHeldCount = rawValue.lock_spin_held_cnt
            self.spinMissCount = rawValue.lock_spin_miss_cnt
            self.mutexUtilCount = rawValue.lock_mtx_util_cnt
            self.mutexHeldCount = rawValue.lock_mtx_held_cnt
            self.mutexMissCount = rawValue.lock_mtx_miss_cnt
            self.mutexWaitCount = rawValue.lock_mtx_wait_cnt
        }
        public let name: String
        public let spinCount: UInt64
        public let mutexCount: UInt64
        public let rwCount: UInt64

        /// - Important: This value is only available on kernels compiled with DTrace support.
        public let spinHeldCount: UInt64
        /// - Important: This value is only available on kernels compiled with DTrace support.
        public let spinMissCount: UInt64
        /// - Important: This value is only available on kernels compiled with DTrace support.
        public let mutexUtilCount: UInt64
        /// - Important: This value is only available on kernels compiled with DTrace support.
        public let mutexHeldCount: UInt64
        /// - Important: This value is only available on kernels compiled with DTrace support.
        public let mutexMissCount: UInt64
        /// - Important: This value is only available on kernels compiled with DTrace support.
        public let mutexWaitCount: UInt64

        // `lockgroup_info_t` has other fields, but they appear to be unused, so they are not included here.
    }
    /// The lock groups in the host.
    public var lockGroups: [LockGroup] {
        get throws {
            var lockGroupInfo: lockgroup_info_array_t?
            var lockGroupCount = mach_msg_type_number_t.max
            try Mach.call(host_lockgroup_info(self.name, &lockGroupInfo, &lockGroupCount))
            return (0..<Int(lockGroupCount)).map {
                LockGroup(rawValue: lockGroupInfo![$0])
            }
        }
    }
}
