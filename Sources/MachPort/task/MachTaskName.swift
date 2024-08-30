@preconcurrency import MachO

/// A Mach task name port.
open class MachTaskName: MachPort {
    typealias RawValue = task_name_t
    /// A null task name port.
    public override class var null: Self {
        Self(rawValue: TASK_NAME_NULL)
    }
    /// Initialize a Mach task name port with the given raw port.
    /// - Parameter rawValue: The raw port.
    public required init(rawValue: task_name_t) {
        guard KernelObject(rawPort: rawValue, rawTask: mach_task_self_)?.type == .taskName else {
            super.init(rawValue: TASK_NULL)
            return
        }
        super.init(rawValue: rawValue)
    }
    /// Initialize a new Mach task name port with the given raw port in the given task.
    public required init(rawValue: task_t, rawTask: MachTask.RawValue) {
        super.init(rawValue: rawValue, rawTask: rawTask)
    }
}
