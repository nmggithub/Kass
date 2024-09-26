import Darwin.Mach

extension Mach {
    /// A port attribute.
    /// - Important: Attributes are only supported on receive rights.
    public enum PortAttribute: mach_port_flavor_t {
        /// The limits of the port.
        case limits = 1

        /// The status of the port.
        /// - Important: This attribute cannot be set.
        case status = 2

        /// The count of requests in the port's request table.
        /// - Important: As of macOS 13.0, setting this attribute has no effect (but doesn't return an error).
        case requestTableCount = 3

        /// Indicates that the receive right will be given to another task.
        /// - Important: This attribute can only be set.
        case tempOwner = 4

        /// Indicates that the receive right is an importance receiver.
        /// - Important: This attribute can only be set.
        case importanceReceiver = 5

        /// Indicates that the receive right is a De-Nap receiver.
        /// - Important: This attribute can only be set.
        @available(macOS, deprecated, message: "Use the importance receiver attribute instead.")
        case deNapReceiver = 6

        /// Information about the port.
        /// - Important: This attribute cannot be set.
        case info = 7

        /// The guard value.
        /// - Important: This attribute can only be asserted, not gotten or set.
        case `guard` = 8

        /// Whether the service is throttled.
        /// - Important: This attribute is only supported on service ports.
        case throttled = 9
    }
}

extension Mach.Port {

    /// Gets the value of a port attribute.
    public func getAttribute<DataType: BitwiseCopyable>(
        _ attribute: Mach.PortAttribute, as type: DataType.Type = DataType.self
    ) throws -> DataType {
        try Mach.callWithCountInOut(type: type) {
            (array: mach_port_info_t, count) in
            mach_port_get_attributes(
                self.owningTask.name, self.name, attribute.rawValue, array, &count
            )
        }
    }

    /// Sets the value of a port attribute.
    public func setAttribute<DataType: BitwiseCopyable>(
        _ attribute: Mach.PortAttribute, to value: DataType
    ) throws {
        try Mach.callWithCountIn(value: value) {
            (array: mach_port_info_t, count) in
            mach_port_set_attributes(
                self.owningTask.name, self.name, attribute.rawValue, array, count
            )
        }
    }

    /// Asserts the value of a port attribute.
    /// - Important: Only the guard attribute can be asserted.
    @available(macOS, introduced: 12.0.1)
    public func assertAttribute<DataType: BitwiseCopyable>(
        _ attribute: Mach.PortAttribute, is value: DataType
    ) throws {
        try Mach.callWithCountIn(value: value) {
            (array: mach_port_info_t, count) in
            mach_port_assert_attributes(
                self.owningTask.name, self.name, attribute.rawValue, array, count
            )
        }
    }
}

extension Mach.Port {
    /// The limits of the port.
    public var limits: mach_port_limits_t { get throws { try self.getAttribute(.limits) } }

    /// Sets the limits of the port.
    public func setLimits(to value: mach_port_limits_t) throws {
        try self.setAttribute(.limits, to: value)
    }

    /// The status of the port.
    public var status: mach_port_status_t { get throws { try self.getAttribute(.status) } }

    /// The count of requests in the port's request table.
    public var requestTableCount: UInt32 {
        get throws { try self.getAttribute(.requestTableCount) }
    }

    /// Sets the count of requests in the port's request table.
    @available(macOS, deprecated: 13.0, message: "Setting this attribute has no effect.")
    public func setRequestTableCount(to value: UInt32) throws {
        try self.setAttribute(.requestTableCount, to: value)
    }

    /// Indicates that the receive right will be given to another task.
    public func setWillChangeOwner() throws { try self.setAttribute(.tempOwner, to: ()) }

    /// Indicates that the receive right is an importance receiver.
    /// - Important: Setting this attribute does the same as setting the De-Nap receiver attribute.
    public func setIsImportanceReceiver() throws {
        try self.setAttribute(.importanceReceiver, to: ())
    }

    /// Indicates that the receive right is a De-Nap receiver.
    /// - Important: Setting this attribute does the same as setting the importance receiver attribute.
    @available(macOS, deprecated, message: "Use `setIsImportanceReceiver()` instead.")
    public func setIsDeNapReceiver() throws { try self.setAttribute(.deNapReceiver, to: ()) }

    /// Information about the port.
    public var info: mach_port_info_ext_t { get throws { try self.getAttribute(.info) } }

    /// Asserts the port's guard value.
    /// - Warning: This will kill the task if the guard value is not as expected.
    @available(macOS, introduced: 12.0.1)
    public func assertGuard(is guard: UInt64) throws {
        try self.assertAttribute(.guard, is: mach_port_guard_info_t(mpgi_guard: `guard`))
    }
}

extension Mach.PortAttribute {
    /// Gets the value of the attribute.
    public func get<DataType: BitwiseCopyable>(
        as type: DataType.Type = DataType.self, for port: Mach.Port
    ) throws -> DataType { try port.getAttribute(self, as: type) }

    /// Sets the value of the attribute.
    public func set<DataType: BitwiseCopyable>(
        to value: DataType, for port: Mach.Port
    ) throws { try port.setAttribute(self, to: value) }

    /// Asserts the value of the attribute.
    @available(macOS, introduced: 12.0.1)
    public func assert<DataType: BitwiseCopyable>(
        is value: DataType, for port: Mach.Port
    ) throws { try port.assertAttribute(self, is: value) }
}
