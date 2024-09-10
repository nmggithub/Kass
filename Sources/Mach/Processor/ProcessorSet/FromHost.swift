import Darwin.Mach

extension Mach.Host {
    /// The processor sets in the host.
    /// - Warning: This returns the name ports for the processor sets. Use `getProcessorSetControl(_:)`
    /// to get the control port for a processor set from its name port.
    public var processorSets: [ProcessorSet] {
        get throws {
            var processorSetList: processor_set_name_array_t?
            var processorSetCount = mach_msg_type_number_t.max
            try Mach.Syscall(host_processor_sets(self.name, &processorSetList, &processorSetCount))
            return (0..<Int(processorSetCount)).map {
                ProcessorSet(named: processorSetList![$0])
            }
        }
    }
    /// Get the control port for a processor set.
    /// - Parameter processorSet: The processor set to get the control port for.
    /// - Throws: If the control port cannot be retrieved.
    /// - Returns: The control port for the processor set.
    public func getProcessorSetControl(_ processorSet: ProcessorSet) throws -> ProcessorSet {
        var controlPortName = mach_port_name_t()
        try Mach.Syscall(
            host_processor_set_priv(self.name, processorSet.name, &controlPortName)
        )
        return ProcessorSet(named: controlPortName)
    }
}
