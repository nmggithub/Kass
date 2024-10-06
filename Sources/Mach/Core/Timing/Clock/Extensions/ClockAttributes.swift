import Darwin.Mach
import KassHelpers

extension Mach {
    /// A type of clock attribute.
    public struct ClockAttribute: KassHelpers.OptionEnum {
        /// The raw value of the clock attribute.
        public let rawValue: clock_flavor_t

        /// Represents a raw clock attribute.
        public init(rawValue: clock_flavor_t) { self.rawValue = rawValue }

        /// The resolution of the clock.
        /// - Important: Technically this is the resolution of the response to a `clock_get_time` call.
        public static let resolution = Self(rawValue: CLOCK_GET_TIME_RES)

        /// The current resolution of the clock.
        @available(*, deprecated, message: "Use `resolution` instead.")
        public static let currentResolution = Self(rawValue: CLOCK_ALARM_CURRES)

        /// The minimum resolution of the clock.
        @available(*, deprecated, message: "Use `resolution` instead.")
        public static let minimumResolution = Self(rawValue: CLOCK_ALARM_MINRES)

        /// The maximum resolution of the clock.
        @available(*, deprecated, message: "Use `resolution` instead.")
        public static let maximumResolution = Self(rawValue: CLOCK_ALARM_MAXRES)
    }
}

extension Mach {
    /// A clock attribute manager.
    public struct ClockAttributeManager: Mach.FlavoredDataGetter {
        /// The clock port.
        public let port: Mach.Clock

        /// The clock.
        internal var clock: Mach.Clock { self.port }

        /// Creates a clock attribute manager.
        public init(port: Mach.Clock) { self.port = port }

        /// Gets the value of a clock attribute.
        public func get<DataType: BitwiseCopyable>(
            _ attribute: Mach.ClockAttribute, as type: DataType.Type = DataType.self
        ) throws -> DataType {
            try Mach.callWithCountInOut(type: type) {
                array, count in
                clock_get_attributes(self.clock.name, attribute.rawValue, array, &count)
            }
        }
    }
}

extension Mach.Clock {
    /// The clock attributes.
    /// - Note: This property is not named `attributes` to avoid conflicting with the `attributes` property of `Mach.Port`.
    public var clockAttributes: Mach.ClockAttributeManager { .init(port: self) }
}
