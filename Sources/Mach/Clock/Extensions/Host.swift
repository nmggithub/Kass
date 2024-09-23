/// Adds clock-related functionality.
extension Mach.Host {
    /// The system clock (uptime).
    public var systemClock: Mach.Clock { get throws { try Mach.Clock(.system, in: self) } }

    /// The calendar clock (POSIX time).
    public var calendarClock: Mach.Clock { get throws { try Mach.Clock(.calendar, in: self) } }

    /// Obtains a clock.
    /// - Parameter type: The type of clock to obtain.
    public func clock(_ type: Mach.Clock.ClockType) throws -> Mach.Clock {
        try Mach.Clock(type, in: self)
    }
}
