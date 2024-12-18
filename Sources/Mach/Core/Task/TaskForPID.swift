import Darwin.Mach
import Foundation

extension Mach.Task {
    /// Gets the task port for a process.
    // This initializer is is marked as `@objc` to allow the BSDCore module to override it and use
    // BSD syscalls for task read and inspect ports. Please see that module for more information.
    @objc public convenience init(forPID pid: pid_t) throws {
        var portName = mach_port_name_t()
        // The first parameter doesn't seem to be used anymore, but we pass in the current task port name for historical reasons.
        switch Self.self {
        case is Mach.TaskName.Type:
            try Mach.call(task_name_for_pid(Mach.Task.current.name, pid, &portName))
        case is Mach.TaskControl.Type:  // We default to the control port.
            fallthrough
        default:
            try Mach.call(task_for_pid(Mach.Task.current.name, pid, &portName))
        }
        self.init(named: portName)
    }
}
