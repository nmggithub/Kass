import BSDBase
import Darwin.Mach
import Linking

private let task_read_for_pid:
    @convention(c) (task_t, pid_t, UnsafeMutablePointer<task_read_t>) -> kern_return_t =
        libSystem()
        .get(symbol: "task_read_for_pid")!.cast()

private let task_inspect_for_pid:
    @convention(c) (task_t, pid_t, UnsafeMutablePointer<task_inspect_t>) -> kern_return_t =
        libSystem()
        .get(symbol: "task_inspect_for_pid")!.cast()

extension Mach.Task {
    /// Gets the task port for a process.
    public static func `for`(pid: pid_t) throws -> Self {
        var portName = mach_port_name_t()
        // The first parameter doesn't seem to be used anymore, but we pass in the current task port name for historical reasons.
        switch Self.self {
        case is Mach.TaskRead.Type:
            try BSD.syscall(task_read_for_pid(Mach.Task.current.name, pid, &portName))  // This is weirdly a BSD syscall, not a Mach call.
        case is Mach.TaskInspect.Type:
            try BSD.syscall(task_inspect_for_pid(Mach.Task.current.name, pid, &portName))  // This is weirdly a BSD syscall, not a Mach call.
        case is Mach.TaskName.Type:
            try Mach.call(task_name_for_pid(Mach.Task.current.name, pid, &portName))
        case is Mach.TaskControl.Type:  // We default to the control port.
            fallthrough
        default:
            try Mach.call(task_for_pid(Mach.Task.current.name, pid, &portName))
        }
        return Self.init(named: portName)
    }
}
