import Darwin.Mach
import Foundation
import MachBase
import MachPort

extension Mach.Task.ControlPort {
    public convenience init(pid: pid_t) throws {
        var controlPort = task_t()
        let ret = task_for_pid(mach_task_self_, pid, &controlPort)
        guard ret == KERN_SUCCESS else {
            throw NSError(domain: NSMachErrorDomain, code: Int(ret))
        }
        self.init(named: controlPort)
    }
}
extension Mach.Task.NamePort {
    public convenience init(pid: pid_t) throws {
        var namePort = task_name_t()
        let ret = task_name_for_pid(mach_task_self_, pid, &namePort)
        guard ret == KERN_SUCCESS else {
            throw NSError(domain: NSMachErrorDomain, code: Int(ret))
        }
        self.init(named: namePort)
    }
}
