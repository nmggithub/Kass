import Darwin.Mach

extension Mach.Task {
    /// Suspends the task.
    public func suspend() throws { try Mach.call(task_suspend(self.name)) }

    /// Resumes the task.
    public func resume() throws { try Mach.call(task_resume(self.name)) }

    /// Terminates the task.
    public func terminate() throws { try Mach.call(task_terminate(self.name)) }
}
