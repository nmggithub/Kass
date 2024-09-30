@preconcurrency import Darwin.Mach

/// A port that can be initialized by looking up a service name.
public protocol InitializableByServiceName: Mach.Port {
    /// Initializes a port by looking up a service name.
    /// - Parameter serviceName: The service name to look up.
    init(serviceName: String) throws
}

extension InitializableByServiceName {
    public init(serviceName: String) throws {
        self.init(named: try Mach.Task.current.bootstrapPort.lookUp(serviceName: serviceName).name)
    }
}
