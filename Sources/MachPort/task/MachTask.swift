import CCompat
@preconcurrency import MachO

/// A Mach task, represented by a task port.
open class MachTask: MachPort {
    public typealias RawValue = task_t
    /// A null task.
    public override class var null: Self {
        Self(rawValue: TASK_NULL, rawTask: mach_task_self_)
    }
    /// The current task.
    public static var current: Self {
        Self(rawValue: mach_task_self_, rawTask: mach_task_self_)
    }
    /// Initialize a Mach task with the given raw port.
    /// - Parameter rawValue: The port.
    public required init(rawValue: task_t) {
        guard KernelObject(rawPort: rawValue, rawTask: mach_task_self_)?.type == .taskControl else {
            super.init(rawValue: TASK_NULL)
            return
        }
        super.init(rawValue: rawValue)
    }
    /// Initialize a new Mach task with the given raw port in the given task.
    public required init(rawValue: task_t, rawTask: MachTask.RawValue) {
        super.init(rawValue: rawValue, rawTask: rawTask)
    }
    /// Initialize a Mach task with the given process ID.
    /// - Parameter pid: The process ID.
    public convenience init(pid: pid_t) {
        var task = task_t()
        // The first parameter doesn't really affect the result, but we set to `mach_task_self_` for historical reasons.
        task_for_pid(mach_task_self_, pid, &task)
        self.init(rawValue: task)
    }

    /// All Mach ports in the current task.
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
        return (0..<Int(namesCount)).map { MachPort(rawValue: names![$0], rawTask: self.rawValue) }
    }

    /// A special port of a Mach task.
    public enum SpecialPort: task_special_port_t, CBinIntMacroEnum {
        case kernel = 1
        case host = 2
        case name = 3
        case bootstrap = 4
        case inspection = 5
        case read = 6
        case seatbelt = 7  // not used
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

    /// The special ports of the Mach task.
    /// - Important: Setting a special port is not guaranteed to succeed, and any errors from the kernel are ignored.
    public struct SpecialPorts {
        internal let task: MachTask
        public subscript<T: MachPort>(portType: SpecialPort, as: T.Type = MachPort.self)
            -> T?
        {
            get {
                var specialPort = T.RawValue()
                let ret = task_get_special_port(self.task.rawValue, portType.rawValue, &specialPort)
                guard ret == KERN_SUCCESS else { return nil }
                return T.init(rawValue: specialPort, rawTask: self.task.rawValue)
            }
            set(newValue) {
                let portToUse = newValue?.rawValue ?? T.RawValue(MACH_PORT_NULL)
                task_set_special_port(self.task.rawValue, portType.rawValue, portToUse)
            }
        }
    }

    /// The special ports of the Mach task.
    public var specialPorts: SpecialPorts {
        get {
            SpecialPorts(task: self)
        }
        set {
            // This is a no-op, as the subscript setter is used to set the special ports. This is just here to tell the compiler that the special ports are settable.
        }
    }
}
