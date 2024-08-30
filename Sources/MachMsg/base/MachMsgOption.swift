import CCompat
import MachO

/// Options for Mach messages.
public enum MachMsgOption: mach_msg_option_t, COptionMacroEnum {
    case send = 0x0000_0001
    case receive = 0x0000_0002
    /// report large message sizes -- `MACH_RCV_LARGE`
    case receiveLarge = 0x0000_0004
    /// identify source of large messages -- `MACH_RCV_LARGE_IDENTITY`
    case receiveLargeIdentity = 0x0000_0008
    /// timeout value applies to send -- `MACH_SEND_TIMEOUT`
    case sendTimeout = 0x0000_0010
    /// priority override for send -- `MACH_SEND_OVERRIDE`
    case sendOverride = 0x0000_0020
    /// don't restart interrupted sends -- `MACH_SEND_INTERRUPT`
    case sendInterrupt = 0x0000_0040
    /// arm send-possible notify -- `MACH_SEND_NOTIFY`
    case sendNotify = 0x0000_0080
    /// rejection by message filter should return failure - user only -- `MACH_SEND_FILTER_NONFATAL`
    case sendFilterNonfatal = 0x0001_0000
    /// sender-provided trailer -- `MACH_SEND_TRAILER`
    case sendTrailer = 0x0002_0000
    /// msg won't carry importance -- `MACH_SEND_NOIMPORTANCE`
    case sendNoimportance = 0x0004_0000
    /// msg should do sync IPC override (on legacy kernels) -- `MACH_SEND_SYNC_OVERRIDE`
    case sendSyncOverride = 0x0010_0000
    /// IPC should propagate the caller's QoS -- `MACH_SEND_PROPAGATE_QOS`
    case sendPropagateQos = 0x0020_0000
    /// special reply port should boost thread doing sync bootstrap checkin -- `MACH_SEND_SYNC_BOOTSTRAP_CHECKIN`
    case sendSyncBootstrapCheckin = 0x0080_0000
    /// timeout value applies to receive -- `MACH_RCV_TIMEOUT`
    case receiveTimeout = 0x0000_0100
    /// don't restart interrupted receive -- `MACH_RCV_INTERRUPT`
    case receiveInterrupt = 0x0000_0400
    /// willing to receive voucher port -- `MACH_RCV_VOUCHER`
    case receiveVoucher = 0x0000_0800
    /// Can receive new guarded descriptor -- `MACH_RCV_GUARDED_DESC`
    case receiveGuardedDesc = 0x0000_1000
    /// sync waiter waiting for rcv -- `MACH_RCV_SYNC_WAIT`
    case receiveSyncWait = 0x0000_4000
    /// sync waiter waiting to peek -- `MACH_RCV_SYNC_PEEK`
    case receiveSyncPeek = 0x0000_8000
    public var cMacroName: String {
        return "MACH_"  // prefix
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
    /// msg carries importance - kernel only -- `MACH_SEND_IMPORTANCE`
    case sendImportance = 0x0008_0000
    /// ignore qlimits - kernel only -- `MACH_SEND_ALWAYS`
    case sendAlways = 0x0001_0000
    /// full send from kernel space - kernel only -- `MACH_SEND_KERNEL`
    case sendKernel = 0x0040_0000
    public var cMacroName: String {
        return "MACH_"  // prefix
            + "\(self)"
            .replacingOccurrences(
                of: "([a-z])([A-Z])", with: "$1_$2", options: .regularExpression
            )
            .uppercased()
    }
}

public typealias MachMsgOptions = COptionMacroSet<MachMsgOption>
