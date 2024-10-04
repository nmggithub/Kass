import Darwin.Mach
import Foundation

extension Mach {
    /// A type of time value.
    public struct TimeType: OptionEnum {
        /// The raw value of the option.
        public let rawValue: alarm_type_t

        /// Represents a raw option.
        public init(rawValue: alarm_type_t) { self.rawValue = rawValue }

        /// The time is absolute.
        public static let absolute = Self(rawValue: TIME_ABSOLUTE)

        /// The time is relative.
        public static let relative = Self(rawValue: TIME_RELATIVE)
    }

    /// A type of clock.
    public struct ClockType: OptionEnum {
        /// The raw value of the option.
        public let rawValue: clock_id_t

        /// Represents a raw option.
        public init(rawValue: clock_id_t) { self.rawValue = rawValue }

        /// The system clock (uptime).
        public static let system = Self(rawValue: SYSTEM_CLOCK)

        /// The calendar clock (POSIX time).
        public static let calendar = Self(rawValue: CALENDAR_CLOCK)
    }
}

extension Mach {
    /// A clock.
    public class Clock: Mach.Port {
        /// Obtains the given clock.
        public convenience init(_ type: Mach.ClockType, onHost host: Mach.Host) throws {
            var clockServicePortName = clock_serv_t()
            try Mach.call(
                host_get_clock_service(host.name, type.rawValue, &clockServicePortName)
            )
            self.init(named: clockServicePortName)
        }

        /// The current time of the clock.
        public var time: mach_timespec_t {
            get throws {
                var time = mach_timespec_t()
                try Mach.call(clock_get_time(self.name, &time))
                return time
            }
        }

        /// The system clock in the current host.
        public static var system: Clock { get throws { try Clock(.system, onHost: .current) } }

        /// The calendar clock in the current host.
        public static var calendar: Clock { get throws { try Clock(.calendar, onHost: .current) } }
    }
}
