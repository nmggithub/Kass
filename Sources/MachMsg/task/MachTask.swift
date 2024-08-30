import Darwin
import System

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
        guard KernelObject(rawPort: rawValue)?.type == .taskControl else {
            super.init(rawValue: TASK_NULL)
            return
        }
        super.init(rawValue: rawValue)
    }
    /// Initialize a Mach task with the given process ID.
    /// - Parameter pid: The process ID.
    public convenience init(pid: pid_t) {
        var task = task_t()
        task_for_pid(mach_task_self_, pid, &task)
        self.init(rawValue: task)
    }
}
