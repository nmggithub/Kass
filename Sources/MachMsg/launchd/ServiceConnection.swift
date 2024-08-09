import Darwin

open class ServiceConnection: MachConnection {
    /// Create a new connection to a service in launchd.
    /// - Parameter serviceName: The name of the service to connect to.
    public init(serviceName: String) throws {
        super.init(port: try bootstrapLookUp(serviceName: serviceName))
    }

    /// Create a new connection to a Mach port.
    /// - Parameter port: The connection port to use.
    /// - Remark:
    ///     Due to the declaration of a designated initializer above, the port-based initializer from `MachConnection`
    ///     cannot be used in subclasses of `ServiceConnection`. This re-declaration is necessary to allow subclasses
    ///     of `ServiceConnection` (such as `MIGConnection`) to use the port-based initializer.
    /// - SeeAlso:
    ///     [Initializer Inheritance and Overriding](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/initialization/#Initializer-Inheritance-and-Overriding)
    internal override init(port: mach_port_t) {
        super.init(port: port)
    }
}
