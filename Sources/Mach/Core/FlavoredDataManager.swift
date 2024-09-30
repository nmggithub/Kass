extension Mach {
    /// An option enumeration of data flavors.
    internal protocol FlavorOptionEnum: OptionEnum {
        /// The data operator type for the flavor enumeration.
        associatedtype ParentDataOperator: PortDataOperator

        /// Gets flavored data for a port.
        func get<DataType: BitwiseCopyable>(
            as type: DataType.Type, for port: ParentDataOperator.ParentPort
        ) throws -> DataType

        /// Sets flavored data for a port.
        func set<DataType: BitwiseCopyable>(
            to value: DataType, for port: ParentDataOperator.ParentPort
        ) throws
    }

    /// A data operator that operates on flavored data for a port.
    internal protocol PortDataOperator {
        associatedtype ParentPort: Mach.Port
        var port: ParentPort { get }
    }

    /// A data operator that can get flavored data for a port.
    internal protocol FlavoredDataGetter: PortDataOperator {
        /// The flavor type.
        associatedtype Flavor: OptionEnum

        /// The port.
        var port: ParentPort { get }

        /// Gets flavored data for the port.
        func get<DataType: BitwiseCopyable>(_ flavor: Flavor, as type: DataType.Type)
            throws -> DataType
    }

    /// A data operator that can set flavored data for a port.
    internal protocol FlavoredDataSetter: PortDataOperator {
        /// The flavor type.
        associatedtype Flavor: OptionEnum

        /// The port.
        var port: ParentPort { get }

        /// Sets flavored data for the port.
        func set<DataType: BitwiseCopyable>(_ flavor: Flavor, to value: DataType)
            throws
    }

    /// A data operator that can get and set flavored data for a port.
    internal protocol FlavoredDataManager: FlavoredDataGetter, FlavoredDataSetter {}
}
