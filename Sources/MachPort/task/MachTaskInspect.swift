@preconcurrency import MachO

/// A wrapper for a Mach task inspect port.
open class MachTaskInspect: MachPort {
    typealias RawValue = task_inspect_t
    /// A null task inspect port.
    public override class var null: Self {
        Self(rawValue: TASK_INSPECT_NULL)
    }
    /// Wrap a given task inspect port.
    /// - Parameter rawValue: The task inspect port.
    /// - Warning: The given port must be a task inspect port in the current task's namespace. If it is not, this initializer will wrap a null task inspect port.
    public required init(rawValue: task_inspect_t) {
        guard KernelObject(rawPort: rawValue, rawTask: mach_task_self_)?.type == .taskInspect else {
            super.init(rawValue: TASK_NULL)
            return
        }
        super.init(rawValue: rawValue)
    }
}
