import BSDBase
import Darwin.Mach
import Linking

extension Mach.Task.ControlPort {
    /// Gets the task control port for a process.
    /// - Parameter pid: The process ID.
    /// - Throws: If the task control port cannot be retrieved.
    public convenience init(forPID pid: pid_t) throws {
        var controlPort = task_t()
        /// The first parameter doesn't seem to be used anymore, but we pass in the current task name for historical reasons.
        try Mach.call(task_for_pid(Mach.Task.current.name, pid, &controlPort))
        self.init(named: controlPort)
    }
}
extension Mach.Task.NamePort {
    /// Gets the task name port for a process.
    /// - Parameter pid: The process ID.
    /// - Throws: If the task name port cannot be retrieved.
    public convenience init(forPID pid: pid_t) throws {
        var namePort = task_name_t()
        /// The first parameter doesn't seem to be used anymore, but we pass in the current task name for historical reasons.
        try Mach.call(task_name_for_pid(Mach.Task.current.name, pid, &namePort))
        self.init(named: namePort)
    }
}

private let task_inspect_for_pid:
    @convention(c) (task_t, pid_t, UnsafeMutablePointer<task_inspect_t>) -> kern_return_t =
        libSystem()
        .get(symbol: "task_inspect_for_pid")!.cast()

extension Mach.Task.InspectPort {
    /// Gets the task inspect port for a process.
    /// - Parameter pid: The process ID.
    /// - Throws: If the task inspect port cannot be retrieved.
    public convenience init(forPID pid: pid_t) throws {
        var namePort = task_inspect_t()
        /// The first parameter doesn't seem to be used anymore, but we pass in the current task name for historical reasons.
        try BSD.syscall(task_inspect_for_pid(Mach.Task.current.name, pid, &namePort))  // This is weirdly a BSD syscall, not a Mach call.
        self.init(named: namePort)
    }
}

private let task_read_for_pid:
    @convention(c) (task_t, pid_t, UnsafeMutablePointer<task_read_t>) -> kern_return_t =
        libSystem()
        .get(symbol: "task_read_for_pid")!.cast()

extension Mach.Task.ReadPort {
    /// Gets the task read port for a process.
    /// - Parameter pid: The process ID.
    /// - Throws: If the task read port cannot be retrieved.
    public convenience init(forPID pid: pid_t) throws {
        var namePort = task_read_t()
        /// The first parameter doesn't seem to be used anymore, but we pass in the current task name for historical reasons.
        try BSD.syscall(task_read_for_pid(Mach.Task.current.name, pid, &namePort))  // This is weirdly a BSD syscall, not a Mach call.
        self.init(named: namePort)
    }
}
