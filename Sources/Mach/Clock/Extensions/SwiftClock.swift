import Darwin.Mach

/// Mathematical helpers for `mach_timespec`.
extension mach_timespec:
    @retroactive Equatable,
    @retroactive AdditiveArithmetic
{
    public static func == (lhs: mach_timespec, rhs: mach_timespec) -> Bool {
        lhs.tv_sec == rhs.tv_sec && lhs.tv_nsec == rhs.tv_nsec
    }

    public static func < (lhs: mach_timespec, rhs: mach_timespec) -> Bool {
        lhs.tv_sec < rhs.tv_sec || (lhs.tv_sec == rhs.tv_sec && lhs.tv_nsec < rhs.tv_nsec)
    }

    public static func - (lhs: mach_timespec, rhs: mach_timespec) -> mach_timespec {
        let (seconds, secondsOverflowed) = lhs.tv_sec.subtractingReportingOverflow(
            rhs.tv_sec
        )
        guard !secondsOverflowed else { fatalError("Overflow!") }
        let nanoseconds = clock_res_t(Int(lhs.tv_nsec) - Int(rhs.tv_nsec))
        return switch true {
        case nanoseconds >= 0: mach_timespec(tv_sec: seconds, tv_nsec: nanoseconds)
        case nanoseconds < 0:
            mach_timespec(
                tv_sec: seconds - 1,
                tv_nsec: clock_res_t(UInt64(nanoseconds) + NSEC_PER_SEC)
            )
        default: fatalError("Unreachable!")
        }
    }

    public static func + (lhs: mach_timespec, rhs: mach_timespec) -> mach_timespec {
        let (seconds, secondsOverflowed) = lhs.tv_sec.addingReportingOverflow(
            rhs.tv_sec
        )
        guard !secondsOverflowed else { fatalError("Overflow!") }
        let nanoseconds = Int(lhs.tv_nsec) + Int(rhs.tv_nsec)
        let overflowedSeconds = UInt64(nanoseconds) / NSEC_PER_SEC
        let actualSeconds = UInt64(seconds) + overflowedSeconds
        guard actualSeconds <= UInt64(UInt32.max) else { fatalError("Overflow!") }
        let actualNanoseconds = UInt64(nanoseconds) % NSEC_PER_SEC
        guard actualNanoseconds <= UInt64(clock_res_t.max) else { fatalError("Overflow!") }
        return mach_timespec(
            tv_sec: UInt32(actualSeconds),
            tv_nsec: clock_res_t(actualNanoseconds)
        )
    }

    public static var zero: mach_timespec { .init(tv_sec: 0, tv_nsec: 0) }
}

extension Mach.Clock: Clock, @unchecked Sendable {
    public struct Duration: DurationProtocol {
        public let value: mach_timespec

        public init(_ value: mach_timespec) { self.value = value }

        public static func - (lhs: Self, rhs: Self) -> Self { Self(lhs.value - rhs.value) }

        public static func + (lhs: Self, rhs: Self) -> Self { Self(lhs.value + rhs.value) }

        public static func / (lhs: Self, rhs: Int) -> Self {
            let doubleValue = lhs / Self(mach_timespec(tv_sec: UInt32(rhs), tv_nsec: 0))
            let seconds = UInt32(doubleValue)
            let nanoseconds = (doubleValue - Double(seconds)) * Double(NSEC_PER_SEC)
            return .init(mach_timespec(tv_sec: seconds, tv_nsec: clock_res_t(nanoseconds)))
        }

        public static func / (lhs: Self, rhs: Self) -> Double {
            guard rhs != Self.zero else { fatalError("Division by zero!") }
            let seconds = Double(lhs.value.tv_sec) / Double(rhs.value.tv_sec)
            let nanoseconds = Double(lhs.value.tv_nsec) / Double(rhs.value.tv_nsec)
            return seconds + (nanoseconds / Double(NSEC_PER_SEC))

        }

        public static func * (lhs: Self, rhs: Int) -> Self {
            let (seconds, secondsOverflowed) = lhs.value.tv_sec.multipliedReportingOverflow(
                by: UInt32(rhs))
            guard !secondsOverflowed else { fatalError("Overflow!") }
            let nanoseconds = Int(lhs.value.tv_nsec) * rhs
            let overflowedSeconds = UInt64(nanoseconds) / NSEC_PER_SEC
            let actualSeconds = UInt64(seconds) + overflowedSeconds
            guard actualSeconds <= UInt64(UInt32.max) else { fatalError("Overflow!") }
            let actualNanoseconds = UInt64(nanoseconds) % NSEC_PER_SEC
            guard actualNanoseconds <= UInt64(clock_res_t.max) else { fatalError("Overflow!") }
            return .init(
                mach_timespec(
                    tv_sec: UInt32(actualSeconds),
                    tv_nsec: clock_res_t(actualNanoseconds)
                )
            )
        }

        public static func < (lhs: Self, rhs: Self) -> Bool { lhs.value < rhs.value }

        public static var zero: Self { .init(mach_timespec(tv_sec: 0, tv_nsec: 0)) }

        public static func == (lhs: Self, rhs: Self) -> Bool { lhs.value == rhs.value }

        public static func != (lhs: Self, rhs: Self) -> Bool { lhs.value != rhs.value }
    }

    public struct Instant: InstantProtocol, Comparable {

        public let value: mach_timespec

        public init(_ value: mach_timespec) { self.value = value }

        public typealias Duration = Mach.Clock.Duration

        public static func < (lhs: Mach.Clock.Instant, rhs: Mach.Clock.Instant) -> Bool {
            lhs.value < rhs.value
        }

        public func advanced(by duration: Duration) -> Instant {
            Instant(self.value + duration.value)
        }

        public func duration(to other: Self) -> Duration {
            Duration(other.value) - Duration(self.value)
        }

        public func hash(into hasher: inout Hasher) {
            hasher.combine(self.value.tv_sec)
            hasher.combine(self.value.tv_nsec)
        }
    }

    /// ***Unsafe.*** The current time of the clock.
    /// - Warning: This property will crash the program if the kernel call fails.
    public var now: Instant { try! .init(self.time) }

    /// ***Unsafe.*** The minimum resolution of the clock.
    /// - Warning: This property will crash the program if the kernel call fails.
    /// - Important: This actually returns the current resolution of the clock, as the minimum resolution
    /// attribute is basically deprecated. Given that the resolution cannot change, this should be fine.
    public var minimumResolution: Duration { try! .init(self.getAttribute(.resolution)) }

    /// ***Unsafe.*** Sleeps until a given time.
    /// - Warning: This property will crash the program if the kernel call fails.
    /// - Important: The `tolerance` parameter is ignored.
    public func sleep(until time: Instant, tolerance: Duration?) async {
        try! self.sleep(until: time.value)
    }
}

extension Mach.Clock.Alarm {
    /// Sets an alarm to ring at a given time.
    public convenience init(
        named name: mach_port_name_t? = nil,
        on clock: Mach.Clock, at time: Mach.Clock.Instant
    ) throws { try self.init(named: name, on: clock, time: time.value, type: .absolute) }

    /// Sets an alarm to ring after a given duration.
    public convenience init(
        named name: mach_port_name_t? = nil,
        on clock: Mach.Clock, after duration: Mach.Clock.Duration
    ) throws { try self.init(named: name, on: clock, time: duration.value, type: .relative) }
}
