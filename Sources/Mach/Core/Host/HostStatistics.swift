import Darwin.Mach

extension Mach {
    /// A flavor of host statistics.
    public struct HostStatisticsFlavor: OptionEnum {
        /// The raw value of the flavor.
        public let rawValue: host_flavor_t

        /// Represents a raw host statistics flavor.
        public init(rawValue: host_flavor_t) { self.rawValue = rawValue }

        /// Load statistics for a host.
        public static let load = Self(rawValue: HOST_LOAD_INFO)

        /// Virtual memory statistics for a host.
        public static let vm = Self(rawValue: HOST_VM_INFO)

        /// CPU load statistics for a host.
        public static let cpuLoad = Self(rawValue: HOST_CPU_LOAD_INFO)

        #if arch(arm64) || arch(x86_64)
            /// virtual memory statistics for a host (64-bit).
            public static let vm64 = Self(rawValue: HOST_VM_INFO64)

            /// External modification statistics for a host.
            public static let extMod = Self(rawValue: HOST_EXTMOD_INFO64)

            /// Power usage statistics for expired tasks on a host.
            public static let expiredTasks = Self(rawValue: HOST_EXPIRED_TASK_INFO)
        #endif
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
                #if arch(arm64) || arch(x86_64)
                    case .vm64, .extMod:
                        host_statistics64(self.host.name, flavor.rawValue, array, &count)
                #endif
                default:
                    #if arch(arm64) || arch(x86_64)
                        host_statistics64(self.host.name, flavor.rawValue, array, &count)
                    #else
                        host_statistics(self.host.name, flavor.rawValue, array, &count)
                    #endif
                }
            }
        }
    }
}

extension Mach.Host {
    /// The host's statistics.
    public var statistics: Mach.HostStatisticsManager { .init(host: self) }
}

extension Mach.HostStatisticsManager {
    /// The load statistics of the host.
    public var load: host_load_info { get throws { try self.get(.load) } }

    /// The virtual memory statistics of the host.
    public var vm: vm_statistics { get throws { try self.get(.vm) } }

    /// The CPU load statistics of the host.
    public var cpuLoad: host_cpu_load_info { get throws { try self.get(.cpuLoad) } }

    /// The 64-bit virtual memory statistics of the host.
    public var vm64: vm_statistics64 { get throws { try self.get(.vm64) } }

    /// The 64-bit external modification statistics of the host.
    public var extMod: vm_extmod_statistics { get throws { try self.get(.extMod) } }

    /// The power usages statistics for expired tasks on the host.
    public var expiredTasks: task_power_info_v2 { get throws { try self.get(.expiredTasks) } }
}
