import CCompat
import Darwin.Mach

extension Mach.VM {
    /// Allocate a new VM region in the task's address space using contiguous physical memory.
    /// - Parameters:
    ///   - host: The host that the task is on.
    ///   - task: The task that will own the memory region.
    ///   - address: The base address of the new VM region.
    ///   - size: The size of the new VM region.
    ///   - flags: The flags that control the allocation.
    /// - Throws: An error if the operation fails.
    public static func allocateCPM(
        host: Mach.Host = .current, task: Mach.Task = .current,
        address: inout vm_address_t, size: vm_size_t,
        flags: Set<Mach.VM.AllocationFlag> = []
    ) throws {
        try Mach.call(
            vm_allocate_cpm(
                host.name, task.name, &address, size, flags.bitmap()
            )
        )
    }
}
