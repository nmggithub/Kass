extension Mach {
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
