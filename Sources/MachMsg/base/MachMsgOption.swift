import CCompat
import MachO

/// Options for Mach messages.
public enum MachMsgOption: mach_msg_option_t, COptionMacroEnum {
    case send = 0x0000_0001
    case receive = 0x0000_0002
    case receiveLarge = 0x0000_0004
    case receiveLargeIdentity = 0x0000_0008
    case sendTimeout = 0x0000_0010
    case sendOverride = 0x0000_0020
    case sendInterrupt = 0x0000_0040
    case sendNotify = 0x0000_0080
    case sendFilterNonfatal = 0x0001_0000
    case sendTrailer = 0x0002_0000
    case sendNoimportance = 0x0004_0000
    case sendSyncOverride = 0x0010_0000
    case sendPropagateQos = 0x0020_0000
    case sendSyncBootstrapCheckin = 0x0080_0000
    case receiveTimeout = 0x0000_0100
    case receiveInterrupt = 0x0000_0400
    case receiveVoucher = 0x0000_0800
    case receiveGuardedDesc = 0x0000_1000
    case receiveSyncWait = 0x0000_4000
    case receiveSyncPeek = 0x0000_8000
    public var cMacroName: String {
        return "MACH_"
            + "\(self)"
            .replacingOccurrences(of: "receive", with: "rcv", options: .literal)
            .replacingOccurrences(
                of: "([a-z])([A-Z])", with: "$1_$2", options: .regularExpression
            )
            .uppercased()
    }
}

/// Kernel options for Mach messages (unused, for now).
public enum MachMsgKernelOption: mach_msg_option_t, COptionMacroEnum {
    case sendImportance = 0x0008_0000
    case sendAlways = 0x0001_0000
    case sendKernel = 0x0040_0000
    public var cMacroName: String {
        return "MACH_"
            + "\(self)"
            .replacingOccurrences(
                of: "([a-z])([A-Z])", with: "$1_$2", options: .regularExpression
            )
            .uppercased()
    }
}

/// A set of options for `mach_msg` calls.
public typealias MachMsgOptions = COptionMacroSet<MachMsgOption>
