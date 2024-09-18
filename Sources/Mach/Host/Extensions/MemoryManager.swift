import Darwin.Mach

extension Mach.Host {
    /// A memory manager.
    public class MemoryManager: Mach.Port {}
    /// Get the default memory manager for the host.
    /// - Throws: An error if the memory manager cannot be retrieved.
    /// - Returns: The default memory manager.
    public func getDefaultMemoryManager() throws -> MemoryManager {
        var name = mach_port_name_t()
        try Mach.call(
            host_default_memory_manager(self.name, &name, 0)
        )
        return MemoryManager(named: name)
    }
    /// Set the default memory manager for the host.
    /// - Parameter manager: The memory manager to set as default.
    /// - Throws: An error if the memory manager cannot be set.
    /// - Warning: Only the kernel can set the default memory manager.
    public func setDefaultMemoryManager(to manager: MemoryManager) throws {
        var name = manager.name
        try Mach.call(
            host_default_memory_manager(self.name, &name, 0)
        )
    }
}
