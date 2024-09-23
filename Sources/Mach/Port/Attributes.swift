import Darwin.Mach

extension Mach.Port {
    /// A port attribute.
    public enum Attribute: mach_port_flavor_t {
        case limits = 1
        case receiveStatus = 2
        case dnRequestsSize = 3
        case tempOwner = 4
        case importanceReceiver = 5
        case denapReceiver = 6
        case infoExt = 7
        case `guard` = 8
        case serviceThrottled = 9
    }
    /// Gets a port attribute.
    /// - Parameters:
    ///   - attribute: The attribute to get.
    ///   - type: The type to load the attribute as.
    /// - Throws: An error if the attribute cannot be retrieved.
    /// - Returns: The attribute.
    public func getAttribute<DataType: BitwiseCopyable>(
        _ attribute: Attribute, as type: DataType.Type = DataType.self
    ) throws -> DataType {
        try Mach.callWithCountInOut(type: type) {
            (array: mach_port_info_t, count) in
            mach_port_get_attributes(
                self.owningTask.name, self.name, attribute.rawValue, array, &count
            )
        }
    }

    /// Sets the value of a port attribute.
    /// - Parameters:
    ///   - attribute: The attribute to set.
    ///   - value: The value to set the attribute to.
    /// - Throws: An error if the attribute cannot be set.
    public func setAttribute<DataType: BitwiseCopyable>(
        _ attribute: Attribute, to value: DataType
    )
        throws
    {
        try Mach.callWithCountIn(value: value) {
            (array: mach_port_info_t, count) in
            mach_port_set_attributes(
                self.owningTask.name, self.name, attribute.rawValue, array, count
            )
        }
    }
}
