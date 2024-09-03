@preconcurrency import Darwin.Mach
import MachPort

/// A port that can be initialized by looking up a service name.
public protocol InitializableByServiceName: MachPort {
    /// Initialize a port by looking up a service name.
    /// - Parameter serviceName: The service name to look up.
    init(serviceName: String) throws
}

extension InitializableByServiceName {
    public init(serviceName: String) throws {
        let bootstrapPort =
            MachTask.current.specialPorts[.bootstrap, BootstrapPort.self]  // attempt to get the bootstrap port functionally
            ?? BootstrapPort(rawValue: bootstrap_port)  // fallback to the kernel-provided symbol for the bootstrap port
        self.init(rawValue: try bootstrapPort.lookUp(serviceName: serviceName).rawValue)
    }
}
