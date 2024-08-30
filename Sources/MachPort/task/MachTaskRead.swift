@preconcurrency import MachO

/// A wrapper for a Mach task read port.
open class MachTaskRead: MachPort {
    typealias RawValue = task_read_t
    /// A null task read port.
    public override class var null: Self {
        Self(rawValue: TASK_READ_NULL)
    }
    /// Wrap a given task read port.
    /// - Parameter rawValue: The task read port.
    /// - Warning: The given port must be a task read port in the current task's namespace. If it is not, this initializer will wrap a null task read port.
    public required init(rawValue: task_read_t) {
        guard KernelObject(rawPort: rawValue, rawTask: mach_task_self_)?.type == .taskRead else {
            super.init(rawValue: TASK_NULL)
            return
        }
        super.init(rawValue: rawValue)
    }
}
