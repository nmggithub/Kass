import Darwin.Mach

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

    /// A host info manager.
    public struct HostInfoManager: FlavoredDataGetter {
        /// The host port.
        internal let port: Mach.Host

        /// The host.
        private var host: Mach.Host { self.port }

        /// Creates a host info manager.
        public init(host: Mach.Host) { self.port = host }

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
