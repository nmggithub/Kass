import Darwin.Mach

extension Mach.Port {
    /// Deallocates the port.
    public func deallocate() throws {
        try Mach.call(mach_port_deallocate(self.owningTask.name, self.name))

    }
}
