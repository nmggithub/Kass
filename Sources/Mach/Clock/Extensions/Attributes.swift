import Darwin.Mach

extension Mach.Clock {
    /// A type of clock attribute.
    public enum Attribute: clock_flavor_t {
        /// The resolution of the clock.
        /// - Important: Technically this is the resolution of the response to a `clock_get_time` call.
        case resolution = 1
        /// The current resolution of the clock.
        @available(*, deprecated, message: "Use `resolution` instead.")
        case currentResolution = 3
        /// The minimum resolution of the clock.
        @available(*, deprecated, message: "Use `resolution` instead.")
        case minimumResolution = 4
        /// The maximum resolution of the clock.
        @available(*, deprecated, message: "Use `resolution` instead.")
        case maximumResolution = 5
    }

    /// Gets the value of a clock attribute.
    /// - Parameters:
    ///   - attribute: The attribute to get.
    ///   - type: The type to load the attribute as.
    /// - Throws: An error if the attribute cannot be retrieved.
    public func getClockAttribute<DataType: BitwiseCopyable>(
        _ attribute: Mach.Clock.Attribute, as type: DataType.Type
    ) throws -> DataType {
        try Mach.callWithCountInOut(type: type) {
            array, count in
            clock_get_attributes(self.name, attribute.rawValue, array, &count)
        }
    }
}
