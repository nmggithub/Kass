open class ServiceConnection: MachConnection {
    /// Create a new connection to a service in launchd.
    /// - Parameter serviceName: The name of the service to connect to.
    convenience init(serviceName: String) throws {
        self.init(port: try bootstrapLookUp(serviceName: serviceName))
    }
}
