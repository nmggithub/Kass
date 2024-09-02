@preconcurrency import MachO
import MachPort

/// A connection to a service.
open class ServicePort: MachPort {
    /// Create a new connection to a service.
    /// - Parameter serviceName: The name of the service to connect to.
    public init(serviceName: String) throws {
        let bootstrapPort =
            MachTask.current.specialPorts[.bootstrap, BootstrapPort.self]  // attempt to get the bootstrap port functionally
            ?? BootstrapPort(rawValue: bootstrap_port)  // fallback to the kernel-provided symbol for the bootstrap port
        super.init(rawValue: try bootstrapPort.lookUp(serviceName: serviceName).rawValue)
    }

    public required init(nilLiteral: ()) {
        super.init(nilLiteral: ())
    }

    public required init(rawValue: mach_port_t) {
        super.init(rawValue: rawValue)
    }

}
