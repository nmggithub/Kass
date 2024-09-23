import Darwin.Mach
import MachHost

extension Mach.Task: Mach.Port.WithSpecialPorts {
    /// A special port for a task.
    public enum SpecialPort: task_special_port_t, Mach.Port.SpecialPortType {
        /// The parent port type.
        public typealias ParentPort = Mach.Task

        /// Gets a special port for the task.
        /// - Parameters:
        ///   - task: The task to get the special port for.
        ///   - type: The type to reference the port as.
        /// - Throws: An error if the port cannot be retrieved.
        /// - Returns: The special port.
        public func get<PortType: Mach.Port>(
            for task: Mach.Task = .current, as type: PortType.Type = Mach.Port.self
        ) throws -> PortType {
            try task.getSpecialPort(self, as: type)
        }

        /// Sets a special port for the task.
        /// - Parameters:
        ///   - task: The task to set the special port for.
        ///   - port: The port to set as the special port.
        /// - Throws: An error if the port cannot be set.
        /// - Returns: The special port.
        public func set(for task: Mach.Task = .current, to port: Mach.Port) throws {
            try task.setSpecialPort(self, to: port)
        }

        /// The task control port.
        case control = 1
        /// The port to the host that the task is in.
        case host = 2
        /// The task name port.
        case name = 3
        /// The bootstrap port, used to get ports for Mach services.
        case bootstrap = 4
        /// The task inspect port.
        case inspect = 5
        /// The task read port.
        case read = 6
        @available(
            macOS, deprecated: 12.0.1,
            message: "The task seatbelt port was removed in macOS Monterey 12.0.1."
        )
        case seatbelt = 7
        @available(
            macOS, deprecated: 10.8,
            message: "This task gssd port was removed in Mac OS X 10.8 Mountain Lion."
        )
        /// - Note: If you can even get Swift code to compile for Max OS X 10.7 Lion or earlier, more power to you.
        case gssd = 8
        /// A port for determining access to the different flavored task ports for the task.
        case access = 9
        case debugControl = 10
        case resourceNotify = 11
    }

    /// Gets a special port for the task.
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
            task_get_special_port(self.name, specialPort.rawValue, &portName)
        )
        return PortType(named: portName)
    }

    /// Sets a special port for the task.
    /// - Parameters:
    ///   - specialPort: The special port to set.
    ///   - port: The port to set as the special port.
    /// - Throws: An error if the port cannot be set.
    public func setSpecialPort(_ specialPort: SpecialPort, to port: Mach.Port) throws {
        try Mach.call(
            task_set_special_port(self.name, specialPort.rawValue, port.name)
        )
    }
}
