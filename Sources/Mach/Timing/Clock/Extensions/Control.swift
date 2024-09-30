import Darwin.Mach
import MachCore

extension Mach {
    /// A clock control port.
    @available(macOS, obsoleted: 13.0)
    public class ClockControl: Mach.Port {
        /// Obtains the control port for the given clock.
        public convenience init(_ type: Mach.ClockType, in host: Mach.Host) throws {
            var clockControlPortName = clock_ctrl_t()
            try Mach.call(
                host_get_clock_control(host.name, type.rawValue, &clockControlPortName)
            )
            self.init(named: clockControlPortName)
        }

        /// Sets the value of a clock attribute.
        public func setAttribute<DataType: BitwiseCopyable>(
            _ attribute: Mach.ClockAttribute, to value: DataType
        ) throws {
            try Mach.callWithCountIn(value: value) {
                (array: clock_attr_t, count) in
                clock_set_attributes(self.name, attribute.rawValue, array, count)
            }
        }

        /// Sets the time of the clock.
        public func setTime(_ time: mach_timespec_t) throws {
            try Mach.call(clock_set_time(self.name, time))
        }
    }
}
