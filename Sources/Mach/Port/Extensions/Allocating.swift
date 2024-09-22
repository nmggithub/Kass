import Darwin.Mach

extension Mach.Port {
    /// Allocates a new port with a given right in the specified task with an optional name.
    /// - Parameters:
    ///   - right: The right to allocate.
    ///   - name: The name to assign to the port.
    ///   - task: The task to allocate the port in.
    /// - Important: Only the ``Right/receive``, ``Right/portSet``, and ``Right/deadName`` rights
    /// are valid for port allocation.
    public convenience init(
        right: Right, named name: mach_port_name_t? = nil, in task: Mach.Task = .current
    ) throws {
        var generatedPortName = mach_port_name_t()
        try Mach.call(
            name != nil
                ? mach_port_allocate_name(task.name, right.rawValue, name!)
                : mach_port_allocate(task.name, right.rawValue, &generatedPortName)
        )
        self.init(named: name ?? generatedPortName)
    }
    /// Deallocates the port.
    public func deallocate() throws {
        try Mach.call(mach_port_deallocate(self.owningTask.name, self.name))
    }
}
