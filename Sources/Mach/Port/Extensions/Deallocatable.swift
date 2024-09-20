import Darwin.Mach

extension Mach.Port {
    /// A port that can be allocated.
    public protocol Deallocatable: Mach.Port {
        /// Deallocates the port.
        func deallocate() throws
    }
}

extension Mach.Port.Deallocatable {
    public func deallocate() throws {
        try Mach.call(mach_port_deallocate(self.owningTask.name, self.name))

    }
}
