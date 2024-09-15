import Darwin.Mach

extension Mach.Port {
    /// A port that can be allocated.
    public protocol Deallocatable: Mach.Port {
        /// Deallocate the port.
        func deallocate() throws
    }
}

extension Mach.Port.Deallocatable {
    public func deallocate() throws {
        try Mach.Call(mach_port_deallocate(self.owningTask.name, self.name))

    }
}
