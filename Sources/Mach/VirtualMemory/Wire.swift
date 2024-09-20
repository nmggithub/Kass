import CCompat
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
        host: Mach.Host = .current, task: Mach.Task = .current,
        address: vm_address_t, size: vm_size_t,
        access: Set<Mach.VM.Protection>
    ) throws {
        guard !access.isEmpty && access != [.none] else {
            // specifying no access protection actually unwires the memory, which we don't want
            fatalError("Specify at least one access protection.")
        }
        try Mach.call(
            vm_wire(host.name, task.name, address, size, access.bitmap())
        )
    }
    /// Unwire a range of memory.
    /// - Parameters:
    ///   - host: The host that the task is on.
    ///   - task: The task that owns the memory range.
    ///   - address: The base address of the memory range.
    ///   - size: The size of the memory range.
    /// - Throws: An error if the operation fails.
    public static func unwire(
        host: Mach.Host = .current, task: Mach.Task = .current,
        address: vm_address_t, size: vm_size_t
    ) throws {
        let access: Set<Mach.VM.Protection> = [.none]
        try Mach.call(
            vm_wire(host.name, task.name, address, size, access.bitmap())
        )
    }
}
