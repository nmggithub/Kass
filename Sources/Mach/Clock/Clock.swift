import Darwin.Mach
import Foundation
@_exported import MachBase
@_exported import MachHost
@_exported import MachPort

extension Mach {
    /// A clock.
    public class Clock: Mach.Port {
        /// A type of time value.
        public enum TimeType: alarm_type_t {
            case absolute = 0
            case relative = 1
        }

        /// A type of clock.
        public enum ClockType: clock_id_t {
            /// The system clock (uptime).
            case system = 0
            /// The calendar clock (POSIX time).
            case calendar = 1
        }

        /// Obtains the given clock.
        public convenience init(_ type: ClockType, in host: Mach.Host) throws {
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
        public static var system: Clock { get throws { try Clock(.system, in: .current) } }

        /// The calendar clock in the current host.
        public static var calendar: Clock { get throws { try Clock(.calendar, in: .current) } }
    }
}
