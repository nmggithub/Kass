import Darwin.Mach

extension Mach.Thread {
    /// Suspend the thread.
    /// - Throws: An error if the operation fails.
    public func suspend() throws { try Mach.call(thread_suspend(self.name)) }
    /// Resume the thread.
    /// - Throws: An error if the operation fails.
    public func resume() throws { try Mach.call(thread_resume(self.name)) }
    /// Abort the thread.
    /// - Parameter safely: Whether to abort the thread safely.
    /// - Throws: An error if the operation fails.
    public func abort(safely: Bool = false) throws {
        try Mach.call(safely ? thread_abort_safely(self.name) : thread_abort(self.name))
    }
}
