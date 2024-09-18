import Darwin.Mach

extension Mach.Host {
    /// The statistics for the host.
    public var statistics: Statistics { .init(for: self) }
    /// Statistics for a host.
    public class Statistics: Mach.FlavoredDataManagerNoAdditionalArgs<
        Statistics.Flavor, host_info_t.Pointee  // statistics use the same type as info
    >
    {
        /// A flavor of host statistics.
        public enum Flavor: host_flavor_t {
            case load = 1
            case vm = 2
            case cpuLoad = 3
            case vm64 = 4
            case extMod = 5
            case expiredTasks = 6
        }
        /// Create a new statistics manager for the host.
        /// - Parameter host: The host to manage statistics for.
        /// - Warning: Setting statistics is not supported.
        public convenience init(for host: Mach.Host) {
            self.init(
                getter: {
                    flavor, array, count, _ in
                    switch flavor {
                    case .load, .vm, .cpuLoad, .expiredTasks:
                        host_statistics(host.name, flavor.rawValue, array, &count)
                    case .vm64, .extMod:
                        host_statistics64(host.name, flavor.rawValue, array, &count)
                    }
                },
                setter: {
                    _, _, _, _ in
                    fatalError("Cannot set host statistics.")
                }
            )
        }
    }
}
