import CCompat
import Darwin.Mach
import Foundation

extension Mach {
    /// A host.
    public class Host: Mach.Port {
        /// The current host.
        public static var current: Self { Self(named: mach_host_self()) }

        /// Wether the host port is privileged.
        /// - Important: This property accessor is throwing as it calls
        /// the kernel to determine the underlying kernel object type.
        /// - Warning: This property accessor will crash the program if
        /// it determines that the port isn't actually a host port.
        public var isPrivileged: Bool {
            get throws {
                switch try self.kernelObject.type {
                case .hostPriv: true
                case .host: false
                default: fatalError("Not a host port at all!")
                }
            }
        }

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
    }
}

extension Mach {
    /// A reboot option.
    public enum HostRebootOption: Int32 {
        case halt = 0x8
        case upsDelay = 0x100
        case debugger = 0x1000
    }
}
extension Mach.Host {
    /// Reboots the host.
    public func reboot(_ options: Set<Mach.HostRebootOption> = []) throws {
        try Mach.call(host_reboot(self.name, options.bitmap()))
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

extension Mach {
    /// A memory manager.
    public class MemoryManager: Mach.Port {}
}
extension Mach.Host {
    /// Gets the default memory manager for the host.
    public func getDefaultMemoryManager() throws -> Mach.MemoryManager {
        var name = mach_port_name_t()
        try Mach.call(
            host_default_memory_manager(self.name, &name, 0)
        )
        return Mach.MemoryManager(named: name)
    }

    /// Sets the default memory manager for the host.
    /// - Warning: Only the kernel task can set the default memory manager.
    public func setDefaultMemoryManager(_ manager: Mach.MemoryManager) throws {
        var name = manager.name
        try Mach.call(
            host_default_memory_manager(self.name, &name, 0)
        )
    }
}
