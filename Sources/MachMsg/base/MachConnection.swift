import MachO
import MachPort

/// A connection to a Mach port.
open class MachConnection {
    /// The port for the connection.
    public let connectionPort: MachPort

    /// Create a new connection to a Mach port.
    /// - Parameter port: The connection port to use.
    public init(port: MachPort) {
        self.connectionPort = port
    }
}
