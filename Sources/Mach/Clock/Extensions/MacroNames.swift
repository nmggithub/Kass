import CCompat

extension Mach.Clock.ClockType: NameableByCMacro {
    public var cMacroName: String {
        switch self {
        case .system: return "SYSTEM_CLOCK"
        case .calendar: return "CALENDAR_CLOCK"
        }
    }
}

extension Mach.Clock.Attribute: NameableByCMacro {
    public var cMacroName: String {
        switch self {
        case .resolution: return "CLOCK_GET_TIME_RES"
        case .currentResolution: return "CLOCK_ALARM_CURRES"
        case .minimumResolution: return "CLOCK_ALARM_MINRES"
        case .maximumResolution: return "CLOCK_ALARM_MAXRES"
        }
    }
}

extension Mach.Clock.TimeType: NameableByCMacro {
    public var cMacroName: String {
        switch self {
        case .absolute: return "TIME_ABSOLUTE"
        case .relative: return "TIME_RELATIVE"
        }
    }
}
