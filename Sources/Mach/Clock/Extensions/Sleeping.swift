import Darwin.Mach

extension Mach.Clock {
    /// Sleeps on the clock until the given time.
    /// - Parameter time: The time to sleep until.
    /// - Throws: An error if the clock could not be slept on.
    /// - Returns: The time at which the clock was woken up.
    /// - Warning: Sleeping on a nil-named clock will sleep on the system clock.
    @discardableResult  // The result is not always needed.
    public func sleep(until time: mach_timespec_t) throws -> mach_timespec_t {
        var returnedTime = mach_timespec_t()
        try Mach.call(clock_sleep(self.name, Self.TimeType.absolute.rawValue, time, &returnedTime))
        return returnedTime
    }

    /// Sleeps on the clock for the given time.
    /// - Parameter time: The time to sleep for.
    /// - Throws: An error if the clock could not be slept on.
    /// - Returns: The time at which the clock was woken up.
    /// - Warning: Sleeping on a nil-named clock will sleep on the system clock.
    @discardableResult  // The result is not always needed.
    public func sleep(for time: mach_timespec_t) throws -> mach_timespec_t {
        var returnedTime = mach_timespec_t()
        try Mach.call(clock_sleep(self.name, Self.TimeType.relative.rawValue, time, &returnedTime))
        return returnedTime
    }
}