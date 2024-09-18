import Darwin.Mach

extension Mach.Task {
    /// A task suspension token.
    public class SuspensionToken: Mach.Port {}
    /// Suspend the task and receive a suspension token.
    public func suspend2() throws -> SuspensionToken {
        var token = task_suspension_token_t()
        try Mach.call(task_suspend2(self.name, &token))
        return SuspensionToken(named: token)
    }
    /// Resume the task with a suspension token.
    public func resume2(with token: SuspensionToken) throws {
        try Mach.call(task_resume2(token.name))
    }
}
