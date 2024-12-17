import Darwin.Mach
import KassHelpers

extension Mach {
    /// A flavor of host info.
    public struct HostInfoFlavor: KassHelpers.OptionEnum {
        /// The raw value of the flavor.
        public let rawValue: host_flavor_t

        /// Represents a raw host info flavor.
        public init(rawValue: host_flavor_t) { self.rawValue = rawValue }

        /// Basic info about a host.
        public static let basic = Self(rawValue: host_flavor_t(HOST_BASIC_INFO))

        /// Scheduling info about a host.
        public static let scheduling = Self(rawValue: host_flavor_t(HOST_SCHED_INFO))

        /// Resource sizes for a host.
        public static let resourceSizes = Self(rawValue: HOST_RESOURCE_SIZES)

        /// Priority info for a host.
        public static let priority = Self(rawValue: HOST_PRIORITY_INFO)

        /// Whether a host supports semaphore traps.
        public static let semaphoreTraps = Self(rawValue: HOST_SEMAPHORE_TRAPS)

        /// Whether a host supports Mach message traps.
        /// - Note: Technically, according to kernel comments, this is whether the kernel has the specific `mach_msg_trap`
        /// function. That function has been deprecated, but this flavor still exists. Really, it appears that this flavor
        /// has always been a no-op regardless (always returning success), so it seems it all doesn't really matter.
        public static let machMsgTraps = Self(rawValue: HOST_MACH_MSG_TRAP)

        /// Information about purgeable virtual memory on a host.
        public static let vmPurgeable = Self(rawValue: HOST_VM_PURGABLE)

        /// Whether a host can has debugger.
        /// - Note: Yes, this is what it's actually called in the kernel.
        public static let canHasDebugger = Self(rawValue: HOST_CAN_HAS_DEBUGGER)

        /// The preferred user space architecture of a host.
        public static let preferredUserSpaceArchitecture = Self(rawValue: HOST_PREFERRED_USER_ARCH)
    }

    /// A host info manager.
    public struct HostInfoManager: FlavoredDataGetter {
        /// The host.
        internal let host: Mach.Host

        /// Creates a host info manager.
        public init(host: Mach.Host) { self.host = host }

        /// Gets the host's information.
        public func get<DataType>(
            _ flavor: HostInfoFlavor, as type: DataType.Type = DataType.self
        ) throws -> DataType where DataType: BitwiseCopyable {
            try Mach.callWithCountInOut(type: type) {
                array, count in
                host_info(self.host.name, flavor.rawValue, array, &count)
            }
        }
    }
}

extension Mach.Host {
    /// The host's info.
    public var info: Mach.HostInfoManager { .init(host: self) }
}

extension Mach.HostInfoManager {
    /// The basic info of the host.
    public var basic: host_basic_info { get throws { try self.get(.basic) } }

    /// The scheduling info of the host.
    public var scheduling: host_sched_info { get throws { try self.get(.scheduling) } }

    /// The resource sizes for the host.
    /// - Warning: This is currently not fully implemented in the kernel, so it will always return an error.
    public var resourceSizes: kernel_resource_sizes { get throws { try self.get(.resourceSizes) } }

    /// The priority info of the host.
    public var priority: host_priority_info { get throws { try self.get(.priority) } }

    /// Whether the host supports semaphore traps.
    /// - Note: The kernel indicates that the host supports semaphore traps by returning with no error.
    public var supportsSemaphoreTraps: () {
        // We don't handle errors, because an error could simply indicate some other failure.
        get throws { try self.get(.semaphoreTraps, as: Void.self) }
    }

    /// Whether the host supports Mach message traps.
    /// - Note: The kernel indicates that the host supports Mach message traps by returning with no error.
    /// - Note: Technically, according to kernel comments, this is whether the kernel has the specific `mach_msg_trap`
    /// function. That function has been deprecated, but this flavor still exists. Really, it appears that this flavor
    /// has always been a no-op regardless (always returning success), so it seems it all doesn't really matter.
    public var supportsMachMsgTraps: () {
        // We don't handle errors, because an error could simply indicate some other failure.
        get throws { try self.get(.machMsgTraps, as: Void.self) }
    }

    /// Information about purgeable virtual memory on the host.
    public var vmPurgeable: vm_purgeable_info_t { get throws { try self.get(.vmPurgeable) } }

    /// Whether the host can has debugger.
    /// - Note: Yes, this is what it's actually called in the kernel.
    public var canHasDebugger: host_can_has_debugger_info {
        get throws { try self.get(.canHasDebugger) }
    }

    /// The preferred user space architecture of the host.
    public var preferredUserSpaceArchitecture: host_preferred_user_arch {
        get throws { try self.get(.preferredUserSpaceArchitecture) }
    }
}
