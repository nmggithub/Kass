import Darwin.Mach

extension Mach.Task {
    /// Suspends the task.
    public func suspend() throws { try Mach.call(task_suspend(self.name)) }

    /// Resumes the task.
    public func resume() throws { try Mach.call(task_resume(self.name)) }

    /// Terminates the task.
    public func terminate() throws { try Mach.call(task_terminate(self.name)) }
}

extension Mach {
    /// A task suspension token.
    public class TaskSuspensionToken: Mach.Port {}
}

extension Mach.Task {

    /// Suspends the task and receive a suspension token.
    public func suspend2() throws -> Mach.TaskSuspensionToken {
        var token = task_suspension_token_t()
        try Mach.call(task_suspend2(self.name, &token))
        return Mach.TaskSuspensionToken(named: token)
    }

    /// Resumes the task with a suspension token.
    public func resume2(_ token: Mach.TaskSuspensionToken) throws {
        try Mach.call(task_resume2(token.name))
    }
}
