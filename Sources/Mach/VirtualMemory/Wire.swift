import Darwin.Mach

extension Mach.VM {
    /// Wire a range of memory.
    /// - Parameters:
    ///   - host: The host that the task is on.
    ///   - task: The task that owns the memory range.
    ///   - address: The base address of the memory range.
    ///   - size: The size of the memory range.
    ///   - access: The access protection of the memory range.
    /// - Throws: An error if the operation fails.
    public static func wire(
        host: Mach.Host = .current, task: Mach.Task,
        address: vm_address_t, size: vm_size_t,
        access: Set<Mach.VM.Protection>
    ) throws {
        try Mach.Call(
            vm_wire(host.name, task.name, address, size, access.reduce(0, { $0 | $1.rawValue }))
        )
    }
}
