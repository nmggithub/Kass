import Darwin.Mach

extension Mach {
    /// A flavor of port attribute.
    /// - Important: Attributes are only supported on receive rights.
    public struct PortAttributeFlavor: OptionEnum {
        /// The raw value of the flavor.
        public let rawValue: mach_port_flavor_t

        /// Represents a raw port attribute flavor.
        public init(rawValue: mach_port_flavor_t) { self.rawValue = rawValue }

        /// The limits of the port.
        public static let limits = Self(rawValue: MACH_PORT_LIMITS_INFO)

        /// The status of the port.
        /// - Important: This attribute cannot be set.
        public static let status = Self(rawValue: MACH_PORT_RECEIVE_STATUS)

        /// The count of requests in the port's request table.
        /// - Important: As of macOS 13.0, setting this attribute has no effect (but doesn't return an error).
        public static let requestTableCount = Self(rawValue: MACH_PORT_DNREQUESTS_SIZE)

        /// Indicates that the receive right will be given to another task.
        /// - Important: This attribute can only be set.
        public static let tempOwner = Self(rawValue: MACH_PORT_TEMPOWNER)

        /// Indicates that the receive right is an importance receiver.
        /// - Important: This attribute can only be set.
        public static let importanceReceiver = Self(rawValue: MACH_PORT_IMPORTANCE_RECEIVER)

        /// Indicates that the receive right is a De-Nap receiver.
        /// - Important: This attribute can only be set.
        @available(macOS, deprecated, message: "Use the importance receiver attribute instead.")
        public static let deNapReceiver = Self(rawValue: MACH_PORT_DENAP_RECEIVER)

        /// Information about the port.
        /// - Important: This attribute cannot be set.
        public static let info = Self(rawValue: MACH_PORT_INFO_EXT)

        /// The guard value.
        /// - Important: This attribute can only be asserted, not gotten or set.
        public static let guardInfo = Self(rawValue: MACH_PORT_GUARD_INFO)

        /// Whether the service is throttled.
        /// - Important: This attribute is only supported on service ports.
        public static let throttled = Self(rawValue: MACH_PORT_SERVICE_THROTTLED)
    }

    /// A port attribute manager.
    public struct PortAttributeManager: FlavoredDataManager {
        /// The port.
        public let port: Mach.Port

        /// Creates a port attribute manager.
        public init(port: Mach.Port) { self.port = port }

        /// Gets the value of a port attribute.
        public func get<DataType>(
            _ flavor: PortAttributeFlavor, as type: DataType.Type = DataType.self
        ) throws -> DataType where DataType: BitwiseCopyable {
            try Mach.callWithCountInOut(type: type) {
                (array: mach_port_info_t, count) in
                mach_port_get_attributes(
                    port.owningTask.name, port.name, flavor.rawValue, array, &count
                )
            }
        }

        /// Sets the value of a port attribute.
        public func set<DataType>(_ flavor: PortAttributeFlavor, to value: DataType) throws
        where DataType: BitwiseCopyable {
            try Mach.callWithCountIn(value: value) {
                (array: mach_port_info_t, count) in
                mach_port_set_attributes(
                    port.owningTask.name, port.name, flavor.rawValue, array, count
                )
            }
        }

        /// Asserts the value of a port attribute.
        @available(macOS, introduced: 12.0.1)
        public func assert<DataType: BitwiseCopyable>(
            _ flavor: Mach.PortAttributeFlavor, is value: DataType
        ) throws {
            try Mach.callWithCountIn(value: value) {
                (array: mach_port_info_t, count) in
                mach_port_assert_attributes(
                    self.port.owningTask.name, self.port.name, flavor.rawValue, array, count
                )
            }
        }
    }
}

extension Mach.Port {
    /// The attributes of the port.
    public var attributes: Mach.PortAttributeManager { .init(port: self) }
}

extension Mach.PortAttributeManager {
    /// The limits of the port.
    public var limits: mach_port_limits_t { get throws { try self.get(.limits) } }

    /// Sets the limits of the port.
    public func setLimits(to value: mach_port_limits_t) throws {
        try self.set(.limits, to: value)
    }

    /// The status of the port.
    public var status: mach_port_status_t { get throws { try self.get(.status) } }

    /// The count of requests in the port's request table.
    public var requestTableCount: UInt32 {
        get throws { try self.get(.requestTableCount) }
    }

    /// Sets the count of requests in the port's request table.
    @available(macOS, deprecated: 13.0, message: "Setting this attribute has no effect.")
    public func setRequestTableCount(to value: UInt32) throws {
        try self.set(.requestTableCount, to: value)
    }

    /// Indicates that the receive right will be given to another task.
    public func setWillChangeOwner() throws { try self.set(.tempOwner, to: ()) }

    /// Indicates that the receive right is an importance receiver.
    /// - Important: Setting this attribute does the same as setting the De-Nap receiver attribute.
    public func setIsImportanceReceiver() throws {
        try self.set(.importanceReceiver, to: ())
    }

    /// Indicates that the receive right is a De-Nap receiver.
    /// - Important: Setting this attribute does the same as setting the importance receiver attribute.
    @available(macOS, deprecated, message: "Set the importance receiver attribute instead.")
    public func setIsDeNapReceiver() throws { try self.set(.deNapReceiver, to: ()) }

    /// Information about the port.
    public var info: mach_port_info_ext_t { get throws { try self.get(.info) } }

    /// Asserts the port's guard value.
    /// - Warning: This will kill the task if the guard value is not as expected.
    @available(macOS, introduced: 12.0.1)
    public func assertGuard(is guardInfo: mach_port_guard_info_t) throws {
        try self.assert(.guardInfo, is: guardInfo)
    }
}
