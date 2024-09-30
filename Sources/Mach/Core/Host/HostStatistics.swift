import Darwin.Mach

extension Mach {
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

    /// A host statistics manager.
    public struct HostStatisticsManager: FlavoredDataGetter {
        /// The host port.
        internal let port: Mach.Host

        /// The host.
        private var host: Mach.Host { self.port }

        /// Creates a host statistics manager.
        public init(host: Mach.Host) { self.port = host }

        /// Gets the host's statistics.
        public func get<DataType>(
            _ flavor: HostStatisticsFlavor, as type: DataType.Type = DataType.self
        ) throws -> DataType where DataType: BitwiseCopyable {
            try Mach.callWithCountInOut(type: type) {
                array, count in
                switch flavor {
                case .load, .vm, .cpuLoad, .expiredTasks:
                    host_statistics(self.host.name, flavor.rawValue, array, &count)
                case .vm64, .extMod:
                    host_statistics64(self.host.name, flavor.rawValue, array, &count)
                default: fatalError("Unsupported host statistics flavor.")
                }
            }
        }
    }
}

extension Mach.Host {
    /// The host's statistics.
    public var statistics: Mach.HostStatisticsManager { .init(host: self) }
}
