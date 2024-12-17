import KassHelpers

extension Mach {
    /// A data operator that can get flavored data.
    public protocol FlavoredDataGetter {
        /// The flavor type.
        associatedtype Flavor: KassHelpers.OptionEnum

        /// Gets flavored data.
        func get<DataType: BitwiseCopyable>(_ flavor: Flavor, as type: DataType.Type)
            throws -> DataType
    }

    /// A data operator that can set flavored data.
    public protocol FlavoredDataSetter {
        /// The flavor type.
        associatedtype Flavor: KassHelpers.OptionEnum

        /// Sets flavored data.
        func set<DataType: BitwiseCopyable>(_ flavor: Flavor, to value: DataType)
            throws
    }

    /// A data operator that can get and set flavored data.
    public protocol FlavoredDataManager: FlavoredDataGetter, FlavoredDataSetter {}
}
