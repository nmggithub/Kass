import Darwin.Mach
@_exported import MachBase
@_exported import MachPort

/// A task.
/// - Note: The actual ``MachBase/Mach/Task`` class can be found in the `MachPort` module. It lives there due to a circular
/// dependency between it and `Mach.Port`. However, the vast majority of functionality for tasks is implemented here in the
/// ``MachTask`` module. Please visit both modules to see the full implementation of this class.
extension Mach.Task {
    /// Sets the physical footprint limit for the task.
    /// - Returns: The old limit.
    public func setPhysicalFootprintLimit(_ limit: Int32) throws -> Int32 {
        var oldLimit: Int32 = 0
        try Mach.call(task_set_phys_footprint_limit(self.name, limit, &oldLimit))
        return oldLimit
    }
}
