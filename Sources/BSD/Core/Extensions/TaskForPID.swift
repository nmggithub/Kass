import Darwin.POSIX
import Linking
import MachCore

// We dynamically link these instead of relying on what would likely be a mostly-empty header file.

private let task_read_for_pid:
    @convention(c) (task_t, pid_t, UnsafeMutablePointer<task_read_t>) -> kern_return_t =
        libSystem()
        .get(symbol: "task_read_for_pid")!.cast()

private let task_inspect_for_pid:
    @convention(c) (task_t, pid_t, UnsafeMutablePointer<task_inspect_t>) -> kern_return_t =
        libSystem()
        .get(symbol: "task_inspect_for_pid")!.cast()

// Getting the task read and inspect ports for a PID requires BSD syscalls, so we use them
// here instead of in the MachCore module (although the syntax is basically the same).

extension Mach.TaskRead {
    convenience init(forPID pid: pid_t) throws {
        var portName = mach_port_name_t()
        // The first parameter doesn't seem to be used anymore, but we pass in the current task port name for historical reasons.
        try BSD.call(task_read_for_pid(Mach.Task.current.name, pid, &portName))
        self.init(named: portName)
    }
}

extension Mach.TaskInspect {
    convenience init(forPID pid: pid_t) throws {
        var portName = mach_port_name_t()
        // The first parameter doesn't seem to be used anymore, but we pass in the current task port name for historical reasons.
        try BSD.call(task_inspect_for_pid(Mach.Task.current.name, pid, &portName))
        self.init(named: portName)
    }
}
