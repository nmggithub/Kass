import Darwin.Mach

extension Mach.Port {
    /// A port that can be destroyed.
    public protocol Destroyable: Mach.Port, Mach.Port.Allocatable {
        /// Destroy the port.
        func destroy() throws
    }
}

extension Mach.Port.Destroyable {
    /// - Warning: This uses `mach_port_destroy`, which is an inherently unsafe API.
    @available(
        macOS, deprecated: 12.0,
        message: "This function uses `mach_port_destroy`, which is deprecated."
    )
    public func destroy() throws {
        try Mach.Syscall(mach_port_destroy(self.owningTask.name, self.name))
    }
}
