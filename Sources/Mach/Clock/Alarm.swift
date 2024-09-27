import Darwin.Mach
import Foundation

extension Mach.Clock {
    /// An alarm on a clock.
    public class Alarm: Mach.Port {
        /// Sets up an alarm on a given clock.
        public convenience init(
            named name: mach_port_name_t? = nil,
            on clock: Mach.Clock, time: mach_timespec_t, type: Mach.Clock.TimeType
        ) throws {
            try self.init(right: .receive, named: name)
            try Mach.call(clock_alarm(clock.name, type.rawValue, time, self.name))
        }

        /// Sends a reply to the alarm.
        public func reply(
            returning: MachError.Code,
            time: mach_timespec_t,
            type: Mach.Clock.TimeType
        ) throws {
            try Mach.call(
                clock_alarm_reply(
                    self.name,
                    // `clock_alarm_reply` passes this into a message header as the remote port disposition, so we copy the send right as to not lose it.
                    Mach.PortDisposition.copySend.rawValue,
                    returning.rawValue,
                    type.rawValue,
                    time
                )
            )
        }
    }
}
