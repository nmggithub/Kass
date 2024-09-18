import Darwin.Mach

extension Mach.Host {
    /// The info for the host.
    public var info: Info { .init(for: self) }
    /// Info for a host.
    public class Info: Mach.FlavoredDataManagerNoAdditionalArgs<
        Info.Flavor, host_info_t.Pointee
    >
    {
        /// A flavor of host info.
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
        /// Create a new info manager for the host.
        /// - Parameter host: The host to manage info for.
        /// - Warning: Setting info is not supported.
        public convenience init(for host: Mach.Host) {
            self.init(
                getter: {
                    flavor, array, count, _ in
                    host_info(host.name, flavor.rawValue, array, &count)
                },
                setter: {
                    _, _, _, _ in
                    fatalError("Cannot set host info.")
                }
            )
        }
    }
}
