import Darwin.Mach

extension Mach {
    /// A special port for a task.
    public enum TaskSpecialPort: task_special_port_t, Mach.Port.SpecialPortType {
        /// The parent port type.
        internal typealias ParentPort = Mach.Task

        /// Gets the special port for a task.
        public func get<PortType: Mach.Port>(
            for task: Mach.Task = .current, as type: PortType.Type = PortType.self
        ) throws -> PortType {
            try task.getSpecialPort(self, as: type)
        }

        /// Sets the special port for a task.
        public func set(for task: Mach.Task = .current, to port: Mach.Port) throws {
            try task.setSpecialPort(self, to: port)
        }

        /// The task's control port.
        case control = 1

        /// The host port for the host that the task is in.
        case host = 2

        /// The task's name port.
        case name = 3

        /// The bootstrap port, used to get ports for Mach services.
        case bootstrap = 4

        /// The task's inspect port.
        case inspect = 5

        /// The task's read port.
        case read = 6

        @available(macOS, obsoleted: 12.0.1)
        case seatbelt = 7

        @available(macOS, obsoleted: 10.8)
        /// - Note: If you can even get Swift code to compile for Max OS X Lion or earlier, more power to you.
        case gssd = 8

        /// A port for determining access to the different flavored task ports for the task.
        case access = 9

        /// The task's debug port.
        case debug = 10
    }

}

extension Mach.Task: Mach.Port.WithSpecialPorts {
    /// Gets a special port for the task.
    public func getSpecialPort<PortType: Mach.Port>(
        _ specialPort: Mach.TaskSpecialPort, as type: PortType.Type = PortType.self
    ) throws -> PortType {
        var portName = mach_port_name_t()
        try Mach.call(
            task_get_special_port(self.name, specialPort.rawValue, &portName)
        )
        return PortType(named: portName)
    }

    /// Sets a special port for the task.
    public func setSpecialPort(_ specialPort: Mach.TaskSpecialPort, to port: Mach.Port) throws {
        try Mach.call(
            task_set_special_port(self.name, specialPort.rawValue, port.name)
        )
    }
}

extension Mach.Task {
    /// The task's control port.
    public var controlPort: Mach.TaskControl {
        get throws { try getSpecialPort(.control) }
    }

    /// The task name port.
    public var namePort: Mach.TaskName {
        get throws { try getSpecialPort(.name) }
    }

    /// The task's inspect port.
    public var inspectPort: Mach.TaskInspect {
        get throws { try getSpecialPort(.inspect) }
    }

    /// The task's read port.
    public var readPort: Mach.TaskRead {
        get throws { try getSpecialPort(.read) }
    }

    /// The access port for the task.
    public var accessPort: Mach.Port {
        get throws { try getSpecialPort(.access) }
    }

    /// The task's debug port.
    public var debugPort: Mach.Port {
        get throws { try getSpecialPort(.debug) }
    }
}
