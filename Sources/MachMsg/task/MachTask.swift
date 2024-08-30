@preconcurrency import MachO

/// A Mach task, represented by a task port.
open class MachTask: MachPort {
    typealias RawValue = task_t
    /// A null task.
    public override class var null: Self {
        Self(rawValue: TASK_NULL)
    }
    /// The current task.
    public static var current: Self {
        Self(rawValue: mach_task_self_)
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
        return (0..<Int(namesCount)).map {
            let port = MachPort(rawValue: names![$0])
            port.task = self
            return port
        }
    }
}
