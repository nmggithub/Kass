import Darwin.Mach
import KassHelpers

extension Mach {
    /// A flavor of processor set statistics.
    public struct ProcessorSetStatisticsFlavor: KassHelpers.OptionEnum {
        /// The raw value of the flavor.
        public let rawValue: processor_set_flavor_t

        /// Represents a raw processor set statistics flavor.
        public init(rawValue: processor_set_flavor_t) { self.rawValue = rawValue }

        /// Load statistics about a processor set.
        public static let load = Self(rawValue: PROCESSOR_SET_LOAD_INFO)
    }

    /// A processor set statistics manager.
    public struct ProcessorSetStatisticsManager: FlavoredDataGetter {
        /// The processor set.
        internal let processorSet: Mach.ProcessorSet

        /// Creates a processor set statistics manager.
        public init(processorSet: Mach.ProcessorSet) { self.processorSet = processorSet }

        /// Gets the processor set's statistics.
        public func get<DataType>(
            _ flavor: Mach.ProcessorSetStatisticsFlavor,
            as type: DataType.Type = DataType.self
        ) throws -> DataType where DataType: BitwiseCopyable {
            try Mach.callWithCountInOut(type: type) {
                (array: processor_set_info_t, count) in
                processor_set_statistics(self.processorSet.name, flavor.rawValue, array, &count)
            }
        }
    }
}

extension Mach.ProcessorSet {
    /// The statistics of the processor set.
    public var statistics: Mach.ProcessorSetStatisticsManager { .init(processorSet: self) }
}

extension Mach.ProcessorSetStatisticsManager {
    /// The processor set's load statistics.
    public var load: processor_set_load_info {
        get throws { try self.get(.load) }
    }
}
