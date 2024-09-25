import Darwin.Mach
import MachHost

extension Mach.Task: Mach.Port.WithSpecialPorts {
    /// A special port for a task.
    public enum SpecialPort: task_special_port_t, Mach.Port.SpecialPortType {
        /// The parent port type.
        public typealias ParentPort = Mach.Task

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

        /// The task control port.
        case control = 1

        /// The host port for the host that the task is in.
        case host = 2

        /// The task name port.
        case name = 3

        /// The bootstrap port, used to get ports for Mach services.
        case bootstrap = 4

        /// The task inspect port.
        case inspect = 5

        /// The task read port.
        case read = 6

        @available(macOS, obsoleted: 12.0.1)
        case seatbelt = 7

        @available(macOS, obsoleted: 10.8)
        /// - Note: If you can even get Swift code to compile for Max OS X Lion or earlier, more power to you.
        case gssd = 8

        /// A port for determining access to the different flavored task ports for the task.
        case access = 9

        case debugControl = 10

        case resourceNotify = 11
    }

    /// Gets a special port for the task.
    public func getSpecialPort<PortType: Mach.Port>(
        _ specialPort: SpecialPort, as type: PortType.Type = PortType.self
    ) throws -> PortType {
        var portName = mach_port_name_t()
        try Mach.call(
            task_get_special_port(self.name, specialPort.rawValue, &portName)
        )
        return PortType(named: portName)
    }

    /// Sets a special port for the task.
    public func setSpecialPort(_ specialPort: SpecialPort, to port: Mach.Port) throws {
        try Mach.call(
            task_set_special_port(self.name, specialPort.rawValue, port.name)
        )
    }
}
