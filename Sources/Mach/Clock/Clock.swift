import Darwin.Mach
import Foundation
@_exported import MachBase
@_exported import MachHost
@_exported import MachMsg  // for Mach.Port.Disposition
@_exported import MachPort

extension Mach {
    /// A clock service.
    public class Clock: Mach.Port {
        /// An alarm on a clock.
        public class Alarm: Mach.Port {
            /// A type of alarm.
            public enum AlarmType: alarm_type_t {
                case absolute = 0
                case relative = 1
            }
        }

        /// Sends a reply to an alarm.
        /// - Parameters:
        ///   - alarm: The alarm to reply to.
        ///   - return: The return value to send.
        ///   - type: The type of alarm.
        ///   - time: The time of the alarm.
        /// - Throws: An error if the alarm reply could not be sent.
        public static func alarmReply(
            alarm: Alarm,
            return: MachError.Code,
            type: Alarm.AlarmType,
            time: mach_timespec_t
        ) throws {
            try Mach.call(
                clock_alarm_reply(
                    alarm.name,
                    // `clock_alarm_reply` passes this into a message header as the remote port disposition, so we copy the send right as to not lose it.
                    Mach.Port.Disposition.copySend.rawValue,
                    `return`.rawValue,
                    type.rawValue,
                    time
                )
            )
        }

        /// A type of clock.
        public enum ClockType: clock_id_t {
            case system = 0
            case calendar = 1
        }

        /// Obtains the given clock service.
        /// - Parameter type: The type of clock to obtain.
        /// - Throws: An error if the clock service could not be obtained.
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
        /// Sets up an alarm on the clock.
        /// - Parameters:
        ///   - time: The time to set the alarm for.
        ///   - alarm: The port to send the alarm reply to.
        /// - Throws: An error if the alarm could not be set.
        public func alarm(at time: mach_timespec_t, alarm: Alarm) throws {
            try Mach.call(
                clock_alarm(self.name, 0, time, alarm.name)
            )
        }

        /// The attributes of the clock.
        public var clockAttributes: Attributes { Attributes(of: self) }

        /// Attributes of a clock.
        public class Attributes: Mach.FlavoredDataManagerNoAdditionalArgs<
            Attributes.Flavor, clock_attr_t.Pointee
        >
        {
            /// Creates a clock attributes manager.
            public convenience init(of clock: Mach.Clock) {
                self.init(
                    getter: {
                        flavor, array, count, _ in
                        clock_get_attributes(clock.name, flavor.rawValue, array, &count)
                    },
                    setter: {
                        _, _, _, _ in
                        fatalError("Cannot set clock attributes.")
                    })
            }

            /// A flavor of clock attribute.
            public enum Flavor: clock_flavor_t {
                /// The resolution of the clock.
                /// - Important: Technically this is the resolution of the *response* to a `clock_get_time` call.
                case resolution = 1
                @available(
                    *, deprecated,
                    message: "This is not relevant anymore. Use `resolution` instead."
                )
                case currentResolution = 3
                @available(
                    *, deprecated,
                    message: "This is not relevant anymore. Use `resolution` instead."
                )
                case minimumResolution = 4
                @available(
                    *, deprecated,
                    message: "This is not relevant anymore. Use `resolution` instead."
                )
                case maximumResolution = 5
            }
        }
    }
}

extension Mach.Host {
    /// The system clock.
    public var systemClock: Mach.Clock { try! Mach.Clock(.system, in: self) }
    /// The calendar clock.
    public var calendarClock: Mach.Clock { try! Mach.Clock(.calendar, in: self) }
    /// Obtains a clock service.
    /// - Parameter type: The type of clock to obtain.
    /// - Throws: An error if the clock service could not be obtained.
    /// - Returns: The clock service.
    public func clock(_ type: Mach.Clock.ClockType) throws -> Mach.Clock {
        try Mach.Clock(type, in: self)
    }
}
