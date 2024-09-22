import Darwin.Mach

extension Mach.Port {
    /// - Warning: This uses `mach_port_destroy`, which is an inherently unsafe API.
    @available(
        macOS, deprecated: 12.0,
        message: "This function uses `mach_port_destroy`, which is deprecated."
    )
    /// Destroys the port.
    public func destroy() throws {
        try Mach.call(mach_port_destroy(self.owningTask.name, self.name))
    }
}
