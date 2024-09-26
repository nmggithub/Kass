import Darwin.Mach

extension Mach.Thread {
    /// Wires a thread.
    /// - Parameter host: The host that the thread is on.
    /// - Throws: An error if the operation fails.
    public func wire(host: Mach.Host = .current) throws {
        try Mach.call(thread_wire(host.name, self.name, 1))
    }
    /// Unwires a thread.
    /// - Parameter host: The host that the thread is on.
    /// - Throws: An error if the operation fails.
    public func unwire(host: Mach.Host = .current) throws {
        try Mach.call(thread_wire(host.name, self.name, 0))
    }
}
