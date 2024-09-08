@preconcurrency import Darwin.Mach
import Foundation
import Linking
import MachBase
import MachPort

private let task_inspect_for_pid:
    @convention(c) (task_t, pid_t, UnsafeMutablePointer<task_inspect_t>) -> kern_return_t =
        libSystem()
        .get(symbol: "task_inspect_for_pid")!.cast()

extension Mach.Task.ControlPort {
    /// Get the task control port for a process.
    /// - Parameter pid: The process ID.
    /// - Throws: If the task control port cannot be retrieved.
    public convenience init(pid: pid_t) throws {
        var controlPort = task_t()
        /// The first argument doesn't seem to be used anymore, but we pass in the current task name for historical reasons.
        let ret = task_for_pid(Mach.Task.current.name, pid, &controlPort)
        guard ret == KERN_SUCCESS else {
            throw NSError(domain: NSMachErrorDomain, code: Int(ret))
        }
        self.init(named: controlPort)
    }
}
extension Mach.Task.NamePort {
    /// Get the task name port for a process.
    /// - Parameter pid: The process ID.
    /// - Throws: If the task name port cannot be retrieved.
    public convenience init(pid: pid_t) throws {
        var namePort = task_name_t()
        /// The first argument doesn't seem to be used anymore, but we pass in the current task name for historical reasons.
        let ret = task_name_for_pid(Mach.Task.current.name, pid, &namePort)
        guard ret == KERN_SUCCESS else {
            throw NSError(domain: NSMachErrorDomain, code: Int(ret))
        }
        self.init(named: namePort)
    }
}

extension Mach.Task.InspectPort {
    /// Get the task inspect port for a process.
    /// - Parameter pid: The process ID.
    /// - Throws: If the task inspect port cannot be retrieved.
    public convenience init(pid: pid_t) throws {
        var namePort = task_inspect_t()
        /// The first argument doesn't seem to be used anymore, but we pass in the current task name for historical reasons.
        let ret = task_inspect_for_pid(Mach.Task.current.name, pid, &namePort)
        guard ret == KERN_SUCCESS else {
            throw NSError(domain: NSMachErrorDomain, code: Int(ret))
        }
        self.init(named: namePort)
    }
}
