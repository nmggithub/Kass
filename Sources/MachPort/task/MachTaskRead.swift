@preconcurrency import Darwin.Mach

/// A task read port.
open class MachTaskRead: MachSpecialPort {
    /// A special initializer for a null task read port.
    /// - Parameter nilLiteral: The nil literal.
    /// - Warning: Do not use this initializer directly. Instead, initialize this class with `nil`.
    public required init(nilLiteral: ()) {
        super.init(rawValue: TASK_READ_NULL)
    }
    typealias RawValue = task_read_t
    /// Represent a given raw task read port.
    /// - Parameter rawValue: The task read port.
    /// - Warning: The given port must be a task read port in the current task's namespace. If it is not, this initializer will return a null task read port.
    public required init(rawValue: task_read_t) {
        guard KernelObject(rawPort: rawValue, rawTask: mach_task_self_)?.type == .taskRead else {
            super.init(nilLiteral: ())
            return
        }
        super.init(rawValue: rawValue)
    }
}
