import BSDBase
@preconcurrency import Darwin.Mach
import Foundation
import Linking

private let task_inspect_for_pid:
    @convention(c) (task_t, pid_t, UnsafeMutablePointer<task_inspect_t>) -> kern_return_t =
        libSystem()
        .get(symbol: "task_inspect_for_pid")!.cast()

private let task_read_for_pid:
    @convention(c) (task_t, pid_t, UnsafeMutablePointer<task_read_t>) -> kern_return_t =
        libSystem()
        .get(symbol: "task_read_for_pid")!.cast()

extension Mach.Task.ControlPort {
    /// Get the task control port for a process.
    /// - Parameter pid: The process ID.
    /// - Throws: If the task control port cannot be retrieved.
    public convenience init(pid: pid_t) throws {
        var controlPort = task_t()
        /// The first parameter doesn't seem to be used anymore, but we pass in the current task name for historical reasons.
        try Mach.Syscall(task_for_pid(Mach.Task.current.name, pid, &controlPort))
        self.init(named: controlPort)
    }
}
extension Mach.Task.NamePort {
    /// Get the task name port for a process.
    /// - Parameter pid: The process ID.
    /// - Throws: If the task name port cannot be retrieved.
    public convenience init(pid: pid_t) throws {
        var namePort = task_name_t()
        /// The first parameter doesn't seem to be used anymore, but we pass in the current task name for historical reasons.
        try Mach.Syscall(task_name_for_pid(Mach.Task.current.name, pid, &namePort))
        self.init(named: namePort)
    }
}

extension Mach.Task.InspectPort {
    /// Get the task inspect port for a process.
    /// - Parameter pid: The process ID.
    /// - Throws: If the task inspect port cannot be retrieved.
    public convenience init(pid: pid_t) throws {
        var namePort = task_inspect_t()
        /// The first parameter doesn't seem to be used anymore, but we pass in the current task name for historical reasons.
        try BSD.Syscall(task_inspect_for_pid(Mach.Task.current.name, pid, &namePort))  // This is weirdly a BSD syscall, not a Mach syscall.
        self.init(named: namePort)
    }
}

extension Mach.Task.ReadPort {
    /// Get the task inspect port for a process.
    /// - Parameter pid: The process ID.
    /// - Throws: If the task inspect port cannot be retrieved.
    public convenience init(pid: pid_t) throws {
        var namePort = task_read_t()
        /// The first parameter doesn't seem to be used anymore, but we pass in the current task name for historical reasons.
        try BSD.Syscall(task_read_for_pid(Mach.Task.current.name, pid, &namePort))  // This is weirdly a BSD syscall, not a Mach syscall.
        self.init(named: namePort)
    }
}
