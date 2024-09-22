import Darwin.Mach
import Foundation
@_exported import MachBase
@_exported import MachHost
@_exported import MachMsg  // for Mach.Port.Disposition
@_exported import MachPort

extension Mach {
    /// A clock.
    public class Clock: Mach.Port {
        /// A type of time.
        public enum TimeType: alarm_type_t {
            /// A time expressed as an absolute time value for the clock.
            case absolute = 0
            /// A time expressed relative to the current time value for the clock.
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
        /// - Parameters:
        ///    - type: The type of clock to obtain.
        ///    - host: The host to obtain the clock from.
        /// - Throws: An error if the clock could not be obtained.
        public convenience init(_ type: ClockType, in host: Mach.Host) throws {
            var clockServicePortName = clock_serv_t()
            try Mach.call(
                host_get_clock_service(host.name, type.rawValue, &clockServicePortName)
            )
            self.init(named: clockServicePortName)
        }

        /// The time of the clock.
        public var time: mach_timespec_t {
            get throws {
                var time = mach_timespec_t()
                try Mach.call(
                    clock_get_time(self.name, &time)
                )
                return time
            }
        }
    }
}
