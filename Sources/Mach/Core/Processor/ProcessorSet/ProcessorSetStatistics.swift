import Darwin.Mach

extension Mach {
    /// A flavor of processor set statistics.
    public struct ProcessorSetStatisticsFlavor: OptionEnum {
        public let rawValue: processor_set_flavor_t
        public init(rawValue: processor_set_flavor_t) { self.rawValue = rawValue }

        /// Load statistics about a processor set.
        public static let loadInfo = Self(rawValue: PROCESSOR_SET_LOAD_INFO)
    }
}

extension Mach.ProcessorSet {
    /// Gets the processor set's statistics.
    public func getStatistics<DataType: BitwiseCopyable>(
        withFlavor flavor: Mach.ProcessorSetStatisticsFlavor, as type: DataType.Type = DataType.self
    ) throws -> DataType {
        try Mach.callWithCountInOut(type: type) {
            (array: processor_set_info_t, count) in
            processor_set_statistics(self.name, flavor.rawValue, array, &count)
        }
    }
}

extension Mach.ProcessorSet {
    /// The processor set's load statistics.
    public var loadStatistics: processor_set_load_info {
        get throws { try getStatistics(withFlavor: .loadInfo) }
    }
}
