import Darwin.Mach

extension Mach.Thread: Mach.Port.WithSpecialPorts {
    /// A special port for a thread.
    public enum SpecialPort: task_special_port_t, Mach.Port.SpecialPortType {
        /// The parent port type.
        public typealias ParentPort = Mach.Thread

        /// Gets a special port for the thread.
        /// - Parameters:
        ///   - thread: The thread to get the special port for.
        ///   - type: The type to reference the port as.
        /// - Throws: An error if the port cannot be retrieved.
        /// - Returns: The special port.
        public func get<PortType: Mach.Port>(
            for thread: Mach.Thread = .current, as type: PortType.Type = Mach.Port.self
        ) throws -> PortType {
            try thread.getSpecialPort(self, as: type)
        }

        /// Sets a special port for the thread.
        /// - Parameters:
        ///   - thread: The thread to set the special port for.
        ///   - port: The port to set as the special port.
        /// - Throws: An error if the port cannot be set.
        public func set(for thread: Mach.Thread = .current, to port: Mach.Port) throws {
            try thread.setSpecialPort(self, to: port)
        }

        case kernel = 1
        case inspect = 2
        case read = 3
    }

    /// Gets a special port for the thread.
    /// - Parameters:
    ///   - specialPort: The special port to get.
    ///   - type: The type to reference the port as.
    /// - Throws: An error if the port cannot be retrieved.
    /// - Returns: The special port.
    public func getSpecialPort<PortType: Mach.Port>(
        _ specialPort: SpecialPort, as type: PortType.Type = Mach.Port.self
    ) throws -> PortType {
        var portName = mach_port_name_t()
        try Mach.call(
            thread_get_special_port(self.name, specialPort.rawValue, &portName)
        )
        return PortType(named: portName)
    }

    /// Sets a special port for the thread.
    /// - Parameters:
    ///   - specialPort: The special port to set.
    ///   - port: The port to set as the special port.
    /// - Throws: An error if the port cannot be set.
    public func setSpecialPort(_ specialPort: SpecialPort, to port: Mach.Port) throws {
        try Mach.call(
            thread_set_special_port(self.name, specialPort.rawValue, port.name)
        )
    }
}
