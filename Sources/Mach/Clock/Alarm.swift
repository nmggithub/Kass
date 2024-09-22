import Darwin.Mach
import Foundation

extension Mach.Clock {
    /// An alarm on a clock.
    public class Alarm: Mach.Port {
        /// Sets up an alarm on a given clock.
        /// - Parameters:
        ///   - name: The name to assign to the alarm port.
        ///   - clock: The clock to set the alarm on.
        ///   - time: The time to set the alarm for.
        ///   - type: The type of the time.
        /// - Throws: An error if the alarm could not be set.
        public convenience init(
            named name: mach_port_name_t? = nil,
            on clock: Mach.Clock, at time: mach_timespec_t, type: Mach.Clock.TimeType
        ) throws {
            try self.init(right: .receive, named: name)
            try Mach.call(
                clock_alarm(clock.name, type.rawValue, time, self.name)
            )
        }

        /// Sends a reply to the alarm.
        /// - Parameters:
        ///   - returning: The return code to send.
        ///   - time: The time of the alarm.
        ///   - type: The type of the time.
        /// - Throws: An error if the alarm reply could not be sent.
        public func reply(
            returning: MachError.Code,
            time: mach_timespec_t,
            type: Mach.Clock.TimeType
        ) throws {
            try Mach.call(
                clock_alarm_reply(
                    self.name,
                    // `clock_alarm_reply` passes this into a message header as the remote port disposition, so we copy the send right as to not lose it.
                    Mach.Port.Disposition.copySend.rawValue,
                    returning.rawValue,
                    type.rawValue,
                    time
                )
            )
        }
    }
}
