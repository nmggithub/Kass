import Darwin.Mach

extension Mach {
    /// A port that can be initialized by looking up a service name.
    public protocol PortInitializableByServiceName: Mach.Port {
        /// Initializes a port by looking up a service name.
        init(serviceName: String) throws
    }

}

extension Mach.PortInitializableByServiceName {
    public init(serviceName: String) throws {
        self.init(named: try Mach.Task.current.bootstrapPort.lookUp(serviceName: serviceName).name)
    }
}
