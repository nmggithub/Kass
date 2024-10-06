import KassHelpers

extension Mach {
    /// A data operator that operates on flavored data for a port.
    public protocol PortDataOperator {
        /// The target port type.
        associatedtype TargetPort: Mach.Port

        /// The port.
        var port: TargetPort { get }
    }

    /// A data operator that can get flavored data for a port.
    public protocol FlavoredDataGetter: PortDataOperator {
        /// The flavor type.
        associatedtype Flavor: KassHelpers.OptionEnum

        /// Gets flavored data for the port.
        func get<DataType: BitwiseCopyable>(_ flavor: Flavor, as type: DataType.Type)
            throws -> DataType
    }

    /// A data operator that can set flavored data for a port.
    public protocol FlavoredDataSetter: PortDataOperator {
        /// The flavor type.
        associatedtype Flavor: KassHelpers.OptionEnum

        /// Sets flavored data for the port.
        func set<DataType: BitwiseCopyable>(_ flavor: Flavor, to value: DataType)
            throws
    }

    /// A data operator that can get and set flavored data for a port.
    public protocol FlavoredDataManager: FlavoredDataGetter, FlavoredDataSetter {}
}
