@preconcurrency import MachO

/// A wrapper for a Mach task inspect port.
open class MachTaskInspect: MachSpecialPort {
    /// A special initializer for a null task inspect port.
    /// - Parameter nilLiteral: The nil literal.
    /// - Warning: Do not use this initializer directly. Instead, initialize this class with `nil`.
    public required init(nilLiteral: ()) {
        super.init(rawValue: TASK_INSPECT_NULL)
    }
    typealias RawValue = task_inspect_t
    /// Wrap a given task inspect port.
    /// - Parameter rawValue: The task inspect port.
    /// - Warning: The given port must be a task inspect port in the current task's namespace. If it is not, this initializer will wrap a null task inspect port.
    public required init(rawValue: task_inspect_t) {
        guard KernelObject(rawPort: rawValue, rawTask: mach_task_self_)?.type == .taskInspect else {
            super.init(nilLiteral: ())
            return
        }
        super.init(rawValue: rawValue)
    }
}
