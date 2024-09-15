import Darwin.Mach

extension Mach.Host.Processor {
    /// Get the processor set that the processor is in.
    public func getAssigment() throws -> Mach.Host.ProcessorSet {
        var processorSet = processor_set_name_t()
        try Mach.Call(processor_get_assignment(self.name, &processorSet))
        return Mach.Host.ProcessorSet(named: processorSet)
    }

    /// Assign the processor to a processor set.
    /// - Parameters:
    ///   - processorSet: The processor set to assign the processor to.
    ///   - wait: ???
    /// - Throws: An error if the processor cannot be assigned.
    /// - Warning: This function always errors as it is not implemented in the XNU kernel.
    public func assign(to processorSet: Mach.Host.ProcessorSet, wait: Bool) throws {
        try Mach.Call(processor_assign(self.name, processorSet.name, wait ? 1 : 0))
    }
}
