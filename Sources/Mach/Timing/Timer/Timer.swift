import MachC.MKTimer
@_exported import MachCore

extension Mach {
    /// Flags for arming a timer.
    public struct TimerArmFlags: OptionSet, Sendable {
        /// The raw value of the flag.
        public let rawValue: Int32

        /// Represents a raw flag.
        public init(rawValue: Int32) { self.rawValue = rawValue }

        /// The timer is a normal timer.
        public static let normal = Self(rawValue: MK_TIMER_NORMAL)

        /// The timer is a critical timer.
        public static let critical = Self(rawValue: MK_TIMER_CRITICAL)
    }
}

extension Mach {
    /// A timer.
    public class Timer: Mach.Port {
        /// The current absolute time (in ticks) for the purposes of using timers.
        public static var absoluteTime: UInt64 { mach_absolute_time() }

        /// Allocates a new timer port.
        /// - Warning: This function returns a nil-named port if there was an error allocating the port.
        public static func allocate() -> Self { Self(named: mk_timer_create()) }

        /// Destroys the timer.
        override public func destroy() throws { try Mach.call(mk_timer_destroy(self.name)) }

        /// Arms the timer to expire at a given time.
        public func arm(expireTime: UInt64) throws {
            try Mach.call(mk_timer_arm(self.name, expireTime))
        }

        /// Arms the timer to expire at a given time.
        public func arm(expireTime: UInt64, flags: Mach.TimerArmFlags = [], leeway: UInt64 = 0)
            throws
        {
            try Mach.call(
                mk_timer_arm_leeway(self.name, UInt64(flags.rawValue), expireTime, leeway)
            )
        }

        /// Cancels the timer and returns the time it was armed to expire at.
        public func cancel() throws -> UInt64 {
            var armedTime = UInt64()
            try Mach.call(mk_timer_cancel(self.name, &armedTime))
            return armedTime
        }
    }
}
