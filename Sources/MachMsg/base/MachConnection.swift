import MachO

/// A connection to a Mach port.
open class MachConnection {
    /// The connection port for the service.
    public let connectionPort: mach_port_t

    /// Create a new connection to a Mach port.
    /// - Parameter port: The connection port to use.
    public init(port: mach_port_t) {
        self.connectionPort = port
    }
}
