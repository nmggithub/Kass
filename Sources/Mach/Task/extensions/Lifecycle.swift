import Darwin.Mach
import Foundation.NSError

extension Mach.Task {
    /// Suspend the task.
    public func suspend() throws {
        let ret = task_suspend(self.name)
        guard ret == KERN_SUCCESS else {
            throw NSError(domain: NSMachErrorDomain, code: Int(ret))
        }
    }
    /// Resume the task.
    public func resume() throws {
        let ret = task_resume(self.name)
        guard ret == KERN_SUCCESS else {
            throw NSError(domain: NSMachErrorDomain, code: Int(ret))
        }
    }
    /// Terminate the task.
    public func terminate() throws {
        let ret = task_terminate(self.name)
        guard ret == KERN_SUCCESS else {
            throw NSError(domain: NSMachErrorDomain, code: Int(ret))
        }
    }
}
