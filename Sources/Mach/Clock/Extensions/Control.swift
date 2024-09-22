import Darwin.Mach

extension Mach {
    /// A clock control port.
    @available(
        macOS, deprecated: 13.0,
        message: "Clock control ports were removed from the kernel in macOS Ventura 13."
    )
    public class ClockControl: Mach.Port {
        /// Obtains the control port for the given clock.
        /// - Parameters:
        ///   - type: The type of clock to obtain the control port for.
        ///   - host: The host to obtain the clock from.
        /// - Throws: An error if the control port for the clock could not be obtained.
        public convenience init(_ type: Clock.ClockType, in host: Mach.Host) throws {
            var clockControlPortName = clock_ctrl_t()
            try Mach.call(
                host_get_clock_control(host.name, type.rawValue, &clockControlPortName)
            )
            self.init(named: clockControlPortName)
        }

        /// Sets the value of a clock attribute.
        /// - Parameters:
        ///   - attribute: The attribute to set.
        ///   - value: The value to set the attribute to.
        /// - Throws: An error if the attribute cannot be set.
        public func setAttribute<DataType: BitwiseCopyable>(
            _ attribute: Mach.Clock.Attribute, to value: DataType
        ) throws {
            try Mach.callWithCountIn(value: value) {
                (array: clock_attr_t, count) in
                clock_set_attributes(self.name, attribute.rawValue, array, count)
            }
        }

        /// Sets the time of the clock.
        /// - Parameter time: The time to set the clock to.
        /// - Throws: An error if the time cannot be set.
        public func setTime(_ time: mach_timespec_t) throws {
            try Mach.call(clock_set_time(self.name, time))
        }
    }
}
