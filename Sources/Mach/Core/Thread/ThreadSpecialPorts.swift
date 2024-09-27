import Darwin.Mach

extension Mach {
    /// A special port for a thread.
    public enum ThreadSpecialPort: task_special_port_t, Mach.Port.SpecialPortType {
        /// The parent port type.
        public typealias ParentPort = Mach.Thread

        /// Gets a special port for the thread.
        public func get<PortType: Mach.Port>(
            for thread: Mach.Thread = .current, as type: PortType.Type = PortType.self
        ) throws -> PortType {
            try thread.getSpecialPort(self, as: type)
        }

        /// Sets a special port for the thread.
        public func set(for thread: Mach.Thread = .current, to port: Mach.Port) throws {
            try thread.setSpecialPort(self, to: port)
        }

        /// A thread's control port.
        case control = 1

        /// A thread's inspect port.
        case inspect = 2

        /// A thread's read port.
        case read = 3
    }
}

extension Mach.Thread: Mach.Port.WithSpecialPorts {
    /// Gets a special port for the thread.
    public func getSpecialPort<PortType: Mach.Port>(
        _ specialPort: Mach.ThreadSpecialPort, as type: PortType.Type = PortType.self
    ) throws -> PortType {
        var portName = mach_port_name_t()
        try Mach.call(
            thread_get_special_port(self.name, specialPort.rawValue, &portName)
        )
        return PortType(named: portName)
    }

    /// Sets a special port for the thread.
    public func setSpecialPort(_ specialPort: Mach.ThreadSpecialPort, to port: Mach.Port) throws {
        try Mach.call(
            thread_set_special_port(self.name, specialPort.rawValue, port.name)
        )
    }
}

extension Mach.Thread {
    /// The thread's control port.
    public var controlPort: Mach.ThreadControl {
        get throws { try getSpecialPort(.control) }
    }

    /// The thread's inspect port.
    public var inspectPort: Mach.ThreadInspect {
        get throws { try getSpecialPort(.inspect) }
    }

    /// The thread's read port.
    public var readPort: Mach.ThreadRead {
        get throws { try getSpecialPort(.read) }
    }
}
