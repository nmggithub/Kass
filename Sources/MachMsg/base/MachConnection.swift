import Darwin

/// A connection to a Mach port.
open class MachConnection: MachMessaging {
    /// The connection port for the service.
    public var connectionPort: mach_port_t

    /// Create a new connection to a Mach port.
    /// - Parameter port: The connection port to use.
    public init(withPort port: mach_port_t) {
        self.connectionPort = port
    }
}
