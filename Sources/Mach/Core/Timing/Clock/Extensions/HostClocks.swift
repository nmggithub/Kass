/// Adds clock-related functionality.
extension Mach.Host {
    /// The system clock (uptime).
    public var systemClock: Mach.Clock { get throws { try Mach.Clock(.system, onHost: self) } }

    /// The calendar clock (POSIX time).
    public var calendarClock: Mach.Clock { get throws { try Mach.Clock(.calendar, onHost: self) } }

    /// Obtains a clock.
    public func clock(_ type: Mach.ClockType) throws -> Mach.Clock {
        try Mach.Clock(type, onHost: self)
    }
}
