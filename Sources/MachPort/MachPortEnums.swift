import CCompat
import Darwin.Mach

/// A right for a port.
public enum MachPortRight: mach_port_right_t, CBinIntMacroEnum, CaseIterable {
    case send = 0
    case receive = 1
    case sendOnce = 2
    case portSet = 3
    case deadName = 4
    case labelh = 5
    case number = 6
    public var cMacroName: String {
        "MACH_PORT_RIGHT_"
            + "\(self)"
            .replacingOccurrences(
                of: "([a-z])([A-Z])", with: "$1_$2", options: .regularExpression
            )
            .uppercased()
    }
}

/// A flag for guarding a port.
public enum MachPortGuardFlag: UInt64, COptionMacroEnum {
    case strict = 1
    case immovableReceive = 2
    public var cMacroName: String {
        "MPG_"
            + "\(self)".replacingOccurrences(
                of: "([a-z])([A-Z])", with: "$1_$2", options: .regularExpression
            ).uppercased()
    }
}

/// A flag for constructing a port.
public enum MachPortConstructFlag: UInt32, COptionMacroEnum {
    case contextAsGuard = 0x01
    case queueLimit = 0x02
    case tempowner = 0x04
    case importanceReceiver = 0x08
    case insertSendRight = 0x10
    case strict = 0x20
    case denapReceiver = 0x40
    case immovableReceive = 0x80
    case filterMsg = 0x100
    case tgBlockTracking = 0x200
    case servicePort = 0x400
    case connectionPort = 0x800
    case replyPort = 0x1000
    case replyPortSemantics = 0x2000
    case provisionalReplyPort = 0x4000
    case provisionalIdProtOutput = 0x8000
    public var cMacroName: String {
        "MPO_"
            + "\(self)".replacingOccurrences(
                of: "([a-z])([A-Z])", with: "$1_$2", options: .regularExpression
            ).uppercased()
    }
}
