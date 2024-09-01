import CCompat
@preconcurrency import MachO

/// A task control port.
open class MachTask: MachSpecialPort {
    public typealias RawValue = task_t
    /// A special initializer for a null task port.
    /// - Parameter nilLiteral: The nil literal.
    /// - Warning: Do not use this initializer directly. Instead, initialize this class with `nil`.
    public required init(nilLiteral: ()) {
        super.init(rawValue: TASK_NULL)
    }
    /// The current task.
    public static var current: Self {
        Self(rawValue: mach_task_self_)
    }
    /// Represent a given raw task control port.
    /// - Parameter rawValue: The raw task control port.
    /// - Warning: The given port must be a task control port in the current task's namespace. If it is not, this initializer will return a null task control port.
    public required init(rawValue: task_t) {
        guard KernelObject(rawPort: rawValue, rawTask: mach_task_self_)?.type == .taskControl else {
            super.init(nilLiteral: ())
            return
        }
        super.init(rawValue: rawValue)
        self.rawTask = self.rawValue
    }
    /// Represent a task with the given process ID.
    /// - Parameter pid: The process ID.
    public convenience init(pid: pid_t) {
        var task = task_t()
        // The first parameter doesn't really affect the result, but we set to `mach_task_self_` for historical reasons.
        task_for_pid(mach_task_self_, pid, &task)
        self.init(rawValue: task)
    }

    /// All ports in the task's namespace.
    public var ports: [any MachPort] {
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
            let portInTask = MachPortImpl(rawValue: names![$0])
            portInTask.rawTask = self.rawValue
            return portInTask
        }
    }
    public typealias SpecialPorts = MachTaskSpecialPorts
    public typealias SpecialPort = MachTaskSpecialPort
    /// The special ports for the task.
    public var specialPorts: SpecialPorts {
        get { SpecialPorts(task: self) }
        // This is a no-op, as the subscript setter is used to set the special ports. This is just here to tell the compiler that the special ports are settable.
        set {}
    }
}
