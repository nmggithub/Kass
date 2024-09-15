import Darwin.Mach

extension Mach.Task {
    /// Suspend the task.
    public func suspend() throws { try Mach.Call(task_suspend(self.name)) }
    /// Resume the task.
    public func resume() throws { try Mach.Call(task_resume(self.name)) }
    /// Terminate the task.
    public func terminate() throws { try Mach.Call(task_terminate(self.name)) }
}
