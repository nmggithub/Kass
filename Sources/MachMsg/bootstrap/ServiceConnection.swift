@preconcurrency import MachO
import MachPort

/// A connection to a service.
open class ServiceConnection: MachConnection {
    /// Create a new connection to a service.
    /// - Parameter serviceName: The name of the service to connect to.
    public init(serviceName: String) throws {
        let bootstrapPort =
            MachTask.current.specialPorts[.bootstrap, BootstrapPort.self]  // attempt to get the bootstrap port functionally
            ?? BootstrapPort(rawValue: bootstrap_port)  // fallback to the kernel-provided symbol for the bootstrap port
        super.init(port: try bootstrapPort.lookUp(serviceName: serviceName))
    }

    // internal to expose to subclasses
    internal override init(port: MachPort) {
        super.init(port: port)
    }
}
