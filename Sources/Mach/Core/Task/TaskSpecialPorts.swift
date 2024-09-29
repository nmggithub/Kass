import Darwin.Mach

extension Mach {
    /// A special port for a task.
    public struct TaskSpecialPort: Mach.Port.SpecialPortType {
        /// The parent port type.
        internal typealias ParentPort = Mach.Task

        public let rawValue: Int32
        public init(rawValue: Int32) { self.rawValue = rawValue }

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
        public static let control = Self(rawValue: TASK_KERNEL_PORT)

        /// The host port for the host that the task is in.
        public static let host = Self(rawValue: TASK_HOST_PORT)

        /// The task's name port.
        public static let name = Self(rawValue: TASK_NAME_PORT)

        /// The bootstrap port, used to get ports for Mach services.
        public static let bootstrap = Self(rawValue: TASK_BOOTSTRAP_PORT)

        /// The task's inspect port.
        public static let inspect = Self(rawValue: TASK_INSPECT_PORT)

        /// The task's read port.
        public static let read = Self(rawValue: TASK_READ_PORT)

        private static let TASK_SEATBELT_PORT: Int32 = 7  // This is commented out in the header file.

        @available(macOS, obsoleted: 12.0.1)
        public static let seatbelt = Self(rawValue: TASK_SEATBELT_PORT)

        private static let TASK_GSSD_PORT: Int32 = 8  // This is commented out in the header file.

        @available(macOS, obsoleted: 10.8)
        /// - Note: If you can even get Swift code to compile for Max OS X Lion or earlier, more power to you.
        public static let gssd = Self(rawValue: TASK_GSSD_PORT)

        /// A port for determining access to the different flavored task ports for the task.
        public static let access = Self(rawValue: TASK_ACCESS_PORT)

        /// The task's debug port.
        public static let debug = Self(rawValue: TASK_DEBUG_CONTROL_PORT)
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
    /// The port for the host that the task is in.
    public var hostPort: Mach.Host {
        get throws { try getSpecialPort(.host) }
    }

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
