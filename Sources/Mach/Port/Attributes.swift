import Darwin.Mach

extension Mach.Port {
    /// The attributes of the port.
    public var attributes: Attributes { Attributes(of: self) }
    /// Attributes of a port.
    public class Attributes: Mach.FlavoredDataManagerNoAdditionalArgs<
        Attributes.Flavor, mach_port_info_t.Pointee
    >
    {
        /// Create a new port attributes manager for the port.
        /// - Parameter port: The port to manage attributes for.
        public convenience init(of port: Mach.Port) {
            self.init(
                getter: {
                    flavor, arrayPointer, count, _ in
                    mach_port_get_attributes(
                        port.owningTask.name, port.name, flavor.rawValue, arrayPointer, &count
                    )
                },
                setter: {
                    flavor, arrayPointer, count, _ in
                    mach_port_set_attributes(
                        port.owningTask.name, port.name, flavor.rawValue, arrayPointer, count
                    )
                })
        }
        /// A flavor of port attribute.
        public enum Flavor: mach_port_flavor_t {
            case limits = 1
            case receiveStatus = 2
            case dnRequestsSize = 3
            case tempOwner = 4
            case importanceReceiver = 5
            case denapReceiver = 6
            case infoExt = 7
            case `guard` = 8
            case serviceThrottled = 9
        }
    }
}
