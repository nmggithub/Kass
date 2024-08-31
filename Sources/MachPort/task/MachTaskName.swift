@preconcurrency import MachO

/// A wrapper for a Mach task name port.
open class MachTaskName: MachSpecialPort {
    /// A special initializer for a null task name port.
    /// - Parameter nilLiteral: The nil literal.
    /// - Warning: Do not use this initializer directly. Instead, initialize this class with `nil`.
    public required init(nilLiteral: ()) {
        super.init(rawValue: TASK_NAME_NULL)
    }
    typealias RawValue = task_name_t
    /// Wrap a given task name port.
    /// - Parameter rawValue: The task name port.
    /// - Warning: The given port must be a task name port in the current task's namespace. If it is not, this initializer will wrap a null task name port.
    public required init(rawValue: task_name_t) {
        guard KernelObject(rawPort: rawValue, rawTask: mach_task_self_)?.type == .taskName else {
            super.init(nilLiteral: ())
            return
        }
        super.init(rawValue: rawValue)
    }
}
