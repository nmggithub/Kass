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
    public struct HostRebootOption: FlagEnum {
        public let rawValue: Int32
        public init(rawValue: Int32) { self.rawValue = rawValue }

        public static let halt = Self(rawValue: HOST_REBOOT_HALT)
        public static let upsDelay = Self(rawValue: HOST_REBOOT_UPSDELAY)
        public static let debugger = Self(rawValue: HOST_REBOOT_DEBUGGER)
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
    /// A flavor of host info.
    public struct HostInfoFlavor: OptionEnum {
        public let rawValue: host_flavor_t
        public init(rawValue: host_flavor_t) { self.rawValue = rawValue }

        public static let basic = Self(rawValue: host_flavor_t(HOST_BASIC_INFO))
        public static let scheduling = Self(rawValue: host_flavor_t(HOST_SCHED_INFO))
        public static let resourceSizes = Self(rawValue: HOST_RESOURCE_SIZES)
        public static let priority = Self(rawValue: HOST_PRIORITY_INFO)
        public static let semaphoreTraps = Self(rawValue: HOST_SEMAPHORE_TRAPS)
        public static let machMsgTrap = Self(rawValue: HOST_MACH_MSG_TRAP)
        public static let vmPurgeable = Self(rawValue: HOST_VM_PURGABLE)
        public static let debugInfo = Self(rawValue: HOST_DEBUG_INFO_INTERNAL)
        /// - Note: Yes, this is what it's actually called.
        public static let canHasDebugger = Self(rawValue: HOST_CAN_HAS_DEBUGGER)
        public static let preferredUserspaceArchitecture = Self(rawValue: HOST_PREFERRED_USER_ARCH)
    }

    /// A flavor of host statistics.
    public struct HostStatisticsFlavor: OptionEnum {
        public let rawValue: host_flavor_t
        public init(rawValue: host_flavor_t) { self.rawValue = rawValue }
        public static let load = Self(rawValue: HOST_LOAD_INFO)
        public static let vm = Self(rawValue: HOST_VM_INFO)
        public static let cpuLoad = Self(rawValue: HOST_CPU_LOAD_INFO)
        public static let vm64 = Self(rawValue: HOST_VM_INFO64)
        public static let extMod = Self(rawValue: HOST_EXTMOD_INFO64)
        public static let expiredTasks = Self(rawValue: HOST_EXPIRED_TASK_INFO)
    }
}

extension Mach.Host {
    /// Gets the host's information.
    public func getInfo<DataType: BitwiseCopyable>(
        _ flavor: Mach.HostInfoFlavor, as type: DataType.Type
    ) throws -> DataType {
        try Mach.callWithCountInOut(type: type) {
            array, count in
            host_info(self.name, flavor.rawValue, array, &count)
        }
    }

    /// Gets the host's statistics.
    public func getStatistics<DataType: BitwiseCopyable>(
        _ flavor: Mach.HostStatisticsFlavor, as type: DataType.Type
    ) throws -> DataType {
        try Mach.callWithCountInOut(type: type) {
            array, count in
            switch flavor {
            case .load, .vm, .cpuLoad, .expiredTasks:
                host_statistics(self.name, flavor.rawValue, array, &count)
            case .vm64, .extMod:
                host_statistics64(self.name, flavor.rawValue, array, &count)
            default: fatalError("Unsupported host statistics flavor.")
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
