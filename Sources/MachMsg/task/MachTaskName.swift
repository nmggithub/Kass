import Darwin

/// A Mach task name port.
open class MachTaskName: MachPort {
    typealias RawValue = task_name_t
    /// A null task name port.
    public override class var null: Self {
        Self(rawValue: TASK_NAME_NULL)
    }
    /// The current task.
    static let current = MachTask(rawValue: mach_task_self_)
    /// Initialize a Mach task name port with the given raw port.
    /// - Parameter rawValue: The raw port.
    public required init(rawValue: task_name_t) {
        guard KernelObject(rawPort: rawValue)?.type == .taskName else {
            super.init(rawValue: TASK_NULL)
            return
        }
        super.init(rawValue: rawValue)
    }
}
