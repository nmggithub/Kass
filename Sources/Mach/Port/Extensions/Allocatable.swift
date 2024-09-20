import Darwin.Mach

extension Mach.Port {
    /// A port that can be allocated.
    public protocol Allocatable: Mach.Port, Mach.Port.Deallocatable {
        /// Allocates a new port with a given right in the specified task with an optional name.
        /// - Parameters:
        ///   - right: The right to allocate.
        ///   - name: The name to assign to the port.
        ///   - task: The task to allocate the port in.
        static func allocate(right: Right, named name: mach_port_name_t?, in task: Mach.Task) throws
            -> Self?
    }
}

extension Mach.Port.Allocatable {
    /// - Important: Only the ``Right/receive``, ``Right/portSet``, and ``Right/deadName`` rights
    /// are valid for port allocation.
    public static func allocate(
        right: Right, named name: mach_port_name_t? = nil, in task: Mach.Task = .current
    ) throws -> Self? {
        guard [.receive, .portSet, .deadName].contains(right) else {
            fatalError("Invalid right for port allocation: \(right)")
        }
        var generatedPortName = mach_port_name_t()
        try Mach.call(
            name != nil
                ? mach_port_allocate_name(task.name, right.rawValue, name!)
                : mach_port_allocate(task.name, right.rawValue, &generatedPortName)
        )
        return self.init(named: name ?? generatedPortName)
    }
}
