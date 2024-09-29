import Darwin.Mach

extension Mach {
    /// A collection of processor set statistics.
    public struct ProcessorSetStatistics: RawRepresentable, Hashable, Sendable {
        public let rawValue: processor_set_flavor_t
        public init(rawValue: processor_set_flavor_t) { self.rawValue = rawValue }

        /// Basic information about the processor set.
        public static let basic = Self(rawValue: PROCESSOR_SET_BASIC_INFO)
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
