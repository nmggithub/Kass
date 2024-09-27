import Darwin.Mach

extension Mach.ProcessorSet {
    /// A collection of processor set statistics.
    public enum Statistics: processor_set_flavor_t {
        case basic = 5
    }

    /// Gets the processor set's statistics.
    /// - Parameters:
    /// - collection: The collection of statistics to get.
    /// - type: The type to load the statistics as.
    /// - Throws: An error if the statistics cannot be retrieved.
    public func getStatistics<DataType: BitwiseCopyable>(
        _ collection: Statistics, as type: DataType.Type
    ) throws -> DataType {
        try Mach.callWithCountInOut(type: type) {
            (array: processor_set_info_t, count) in
            processor_set_statistics(self.name, collection.rawValue, array, &count)
        }
    }
}
