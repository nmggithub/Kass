import CCompat
@preconcurrency import MachO

/// A wrapper for a Mach task control port.
open class MachTask: MachPort {
    public typealias RawValue = task_t
    /// A null task.
    public override class var null: Self {
        Self(rawValue: TASK_NULL)
    }
    /// The current task.
    public static var current: Self {
        Self(rawValue: mach_task_self_)
    }
    /// Wrap a given task control port.
    /// - Parameter rawValue: The task control port.
    /// - Warning: The given port must be a task control port in the current task's namespace. If it is not, this initializer will wrap a null task control port.
    public required init(rawValue: task_t) {
        guard KernelObject(rawPort: rawValue, rawTask: mach_task_self_)?.type == .taskControl else {
            super.init(rawValue: TASK_NULL)
            return
        }
        super.init(rawValue: rawValue)
        self.rawTask = self.rawValue
    }
    /// Wrap a Mach task with the given process ID.
    /// - Parameter pid: The process ID.
    public convenience init(pid: pid_t) {
        var task = task_t()
        // The first parameter doesn't really affect the result, but we set to `mach_task_self_` for historical reasons.
        task_for_pid(mach_task_self_, pid, &task)
        self.init(rawValue: task)
    }

    /// All Mach ports in the task's namespace.
    public var ports: [MachPort] {
        var namesCount = mach_msg_type_number_t.max
        var names: mach_port_name_array_t? = mach_port_name_array_t.allocate(
            capacity: Int(namesCount)
        )
        // the types array is not used, but it is required by `mach_port_names`
        var typesCount = mach_msg_type_number_t.max
        var types: mach_port_type_array_t? = mach_port_type_array_t.allocate(
            capacity: Int(typesCount)
        )
        let ret = mach_port_names(self.rawValue, &names, &namesCount, &types, &typesCount)
        guard ret == KERN_SUCCESS else { return [] }
        return (0..<Int(namesCount)).map {
            let portInTask = MachPort(rawValue: names![$0])
            portInTask.rawTask = self.rawValue
            return portInTask
        }
    }

    /// A type of special port for a Mach task.
    public enum SpecialPort: task_special_port_t, CBinIntMacroEnum {
        case kernel = 1
        case host = 2
        case name = 3
        case bootstrap = 4
        case inspection = 5
        case read = 6
        @available(
            *, deprecated, message: "This task special port type is commented out in the kernel."
        )
        case seatbelt = 7  // not used
        @available(
            *, deprecated, message: "This task special port type is commented out in the kernel."
        )
        case gssd = 8  // not used
        case access = 9
        case debugControl = 10
        case resourceNotify = 11
        public var cMacroName: String {
            "TASK_"
                + "\(self)"
                .replacingOccurrences(
                    of: "([a-z])([A-Z])", with: "$1_$2", options: .regularExpression
                )
                .uppercased() + "_PORT"
        }
    }

    /// A container of special ports for a Mach task.
    /// - Important: Setting a special port is not guaranteed to succeed, and any errors from the kernel are ignored.
    public struct SpecialPorts {
        internal let task: MachTask
        /// Get or set a special port for the Mach task.
        /// - Parameters:
        ///   - portType: The type of the special port.
        ///   - portClass: The class of the special port.
        public subscript<T: MachPort>(portType: SpecialPort, portClass: T.Type = MachPort.self)
            -> T?
        {
            get {
                var rawPort = T.RawValue()
                let ret = task_get_special_port(self.task.rawValue, portType.rawValue, &rawPort)
                guard ret == KERN_SUCCESS else { return nil }
                let port = T.init(rawValue: rawPort)
                port.rawTask = self.task.rawValue
                return port
            }
            set(newValue) {
                let portToUse = newValue?.rawValue ?? T.RawValue(MACH_PORT_NULL)
                task_set_special_port(self.task.rawValue, portType.rawValue, portToUse)
            }
        }
    }

    /// The special ports for the Mach task.
    public var specialPorts: SpecialPorts {
        get {
            SpecialPorts(task: self)
        }
        set {
            // This is a no-op, as the subscript setter is used to set the special ports. This is just here to tell the compiler that the special ports are settable.
        }
    }
}
