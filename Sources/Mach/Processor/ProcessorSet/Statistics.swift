import Darwin.Mach

extension Mach.Host.ProcessorSet {
    /// The statistics of the processor set.
    public var statistics: Statistics { Statistics(for: self) }
    /// Statistics for a processor set.
    public class Statistics: Mach.FlavoredDataManagerNoAdditionalArgs<
        Statistics.Flavor, processor_set_info_t.Pointee
    >
    {
        /// Creates a new statistics manager for a processor set.
        /// - Parameter processorSet: The processor set to manage statistics for.
        /// - Warning: Setting statistics is not supported.
        public convenience init(for processorSet: Mach.Host.ProcessorSet) {
            self.init(
                getter: {
                    flavor, info, count, _ in
                    processor_set_statistics(
                        processorSet.name, flavor.rawValue,
                        info, &count
                    )
                },
                setter: {
                    _, _, _, _ in
                    fatalError("Processor set statistics cannot be set.")
                })
        }
        public enum Flavor: processor_set_flavor_t {
            case basic = 5
        }

        /// Gets a processor set's statistics.
        /// - Parameters:
        ///   - flavor: The flavor of the statistics.
        ///   - type: The type to load the statistics as.
        /// - Throws: An error if the statistics cannot be retrieved.
        /// - Returns: The processor set's statistics.
        public func get<StatisticsType>(_ flavor: Flavor, as type: StatisticsType.Type) throws
            -> StatisticsType
        {
            try super.get(flavor, as: type)
        }
        @available(
            *, unavailable, message: "Setting processor set statistics is not supported."
        )
        public override func set<DataType>(
            _ flavor: Flavor, to value: consuming DataType, additional: Never? = nil
        ) throws {}
    }

}
