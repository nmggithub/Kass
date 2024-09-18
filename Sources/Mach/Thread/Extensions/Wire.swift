import Darwin.Mach
import MachHost

extension Mach.Thread {
    /// Wire a thread.
    /// - Parameter host: The host that the thread is on.
    /// - Throws: An error if the operation fails.
    public func wire(host: Mach.Host = .current) throws {
        try Mach.call(thread_wire(host.name, self.name, 1))
    }
    /// Unwire a thread.
    /// - Parameter host: The host that the thread is on.
    /// - Throws: An error if the operation fails.
    public func unwire(host: Mach.Host = .current) throws {
        try Mach.call(thread_wire(host.name, self.name, 0))
    }
}
