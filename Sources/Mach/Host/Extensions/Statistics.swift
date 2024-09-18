import Darwin.Mach

extension Mach.Host {
    /// The statistics for the host.
    public var statistics: Statistics { .init(for: self) }
    /// Statistics for a host.
    public class Statistics: Mach.FlavoredDataManagerNoAdditionalArgs<
        Statistics.Flavor, host_info_t.Pointee
    >
    {
        /// A flavor of host statistics.
        public enum Flavor: host_flavor_t {
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
        /// Create a new statistics manager for the host.
        /// - Parameter host: The host to manage statistics for.
        /// - Warning: Setting statistics is not supported.
        public convenience init(for host: Mach.Host) {
            self.init(
                getter: {
                    flavor, array, count, _ in
                    host_statistics(host.name, flavor.rawValue, array, &count)
                },
                setter: {
                    _, _, _, _ in
                    fatalError("Cannot set host statistics.")
                }
            )
        }
    }
}
