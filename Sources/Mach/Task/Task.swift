import Darwin.Mach
@_exported import MachBase
@_exported import MachPort  // Mach.Task lives in MachPort due to a circular dependency with Mach.Port
@_exported import MachThread

typealias MachTask = Mach.Task

extension Mach.Task {
    /// Sets the physical footprint limit for the task.
    /// - Returns: The old limit.
    public func setPhysicalFootprintLimit(_ limit: Int32) throws -> Int32 {
        var oldLimit: Int32 = 0
        try Mach.call(task_set_phys_footprint_limit(self.name, limit, &oldLimit))
        return oldLimit
    }
}
