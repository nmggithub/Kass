import Darwin

/// A connection to a service in launchd.
open class ServiceConnection: MachConnection {
    /// The connection port for the service.
    public var connectionPort: mach_port_t

    /// Create a new connection to a service in launchd.
    /// - Parameter serviceName: The name of the service to connect to.
    public init(withServiceName serviceName: String) throws {
        self.connectionPort = try bootstrapLookUp(serviceName: serviceName)
    }

    /// Create a new connection to a service in launchd.
    /// - Parameter port: The connection port to use.
    public init(withPort port: mach_port_t) {
        self.connectionPort = port
    }
}
