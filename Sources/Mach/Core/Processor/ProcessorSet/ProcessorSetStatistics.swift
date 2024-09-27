import Darwin.Mach

extension Mach {
    /// A collection of processor set statistics.
    public enum ProcessorSetStatistics: processor_set_flavor_t {
        case basic = 5
    }
}

extension Mach.ProcessorSet {
    /// Gets the processor set's statistics.
    public func getStatistics<DataType: BitwiseCopyable>(
        _ collection: Mach.ProcessorSetStatistics, as type: DataType.Type
    ) throws -> DataType {
        try Mach.callWithCountInOut(type: type) {
            (array: processor_set_info_t, count) in
            processor_set_statistics(self.name, collection.rawValue, array, &count)
        }
    }
}
