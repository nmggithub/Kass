@preconcurrency import MachO

/// A wrapper for a Mach task name port.
open class MachTaskName: MachPort {
    typealias RawValue = task_name_t
    /// A null task name port.
    public override class var null: Self {
        Self(rawValue: TASK_NAME_NULL)
    }
    /// Wrap a given task name port.
    /// - Parameter rawValue: The task name port.
    /// - Warning: The given port must be a task name port in the current task's namespace. If it is not, this initializer will wrap a null task name port.
    public required init(rawValue: task_name_t) {
        guard KernelObject(rawPort: rawValue, rawTask: mach_task_self_)?.type == .taskName else {
            super.init(rawValue: TASK_NULL)
            return
        }
        super.init(rawValue: rawValue)
    }
}
