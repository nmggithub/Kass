import Darwin.Mach

extension Mach {
    /// A port that can be initialized by a service name.
    public protocol PortInitializableByServiceName: Mach.Port {
        init(serviceName: String) throws
    }

    /// A port that can be initialized by looking up service name.
    public protocol ClientInitializableByServiceName: PortInitializableByServiceName {}

    /// A port that can be initialized by registering a service name.
    public protocol ServerInitializableByServiceName: PortInitializableByServiceName {}
}

extension Mach.ClientInitializableByServiceName {
    /// Initializes a port by looking up a service name.
    public init(serviceName: String) throws {
        self.init(named: try Mach.Task.current.bootstrapPort.lookUp(serviceName: serviceName).name)
    }
}

extension Mach.ServerInitializableByServiceName {
    /// Initializes a port by registering a service name.
    public init(serviceName: String) throws {
        let receiveRight = try Self.allocate(right: .receive)
        let sendRight = try receiveRight.extractRight(using: .makeSend)
        try Mach.Task.current.bootstrapPort.register(
            serviceName: serviceName, port: sendRight
        )
        self.init(named: receiveRight.name)
    }
}
