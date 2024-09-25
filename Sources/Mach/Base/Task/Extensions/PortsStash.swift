import Darwin.Mach

extension Mach.Task {
    /// The task's stashed ports.
    public var stashedPorts: [Mach.Port] {
        get throws {
            var portsCount = mach_msg_type_number_t.max
            var ports: mach_port_array_t? = mach_port_array_t.allocate(
                capacity: Int(portsCount)
            )
            try Mach.call(mach_ports_lookup(self.name, &ports, &portsCount))
            return (0..<Int(portsCount)).map {
                let port = Mach.Port(named: ports![$0], in: self)
                return port
            }
        }
    }

    /// Sets the task's stashed ports.
    public func setStashedPorts(_ ports: [Mach.Port]) throws {
        let portsCount = mach_msg_type_number_t(ports.count)
        var portNames = ports.map(\.name)
        try Mach.call(mach_ports_register(self.name, &portNames, portsCount))
    }
}
