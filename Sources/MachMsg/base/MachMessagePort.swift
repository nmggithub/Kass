import CCompat
import MachO
import MachPort

/// A disposition for a port.
public enum MachPortDisposition: mach_msg_type_name_t, CBinIntMacroEnum {
    /// - Warning: This value is not a valid disposition. It is only used to represent an unknown disposition.
    case unknown = 0xFFFF_FFFF
    case none = 0
    case moveReceive = 16
    case moveSend = 17
    case moveSendOnce = 18
    case copySend = 19
    case makeSend = 20
    case makeSendOnce = 21
    case copyReceive = 22
    case disposeReceive = 24
    case disposeSend = 25
    case disposeSendOnce = 26
    /// The name of the C macro that represents the disposition.
    public var cMacroName: String {
        switch self {
        case .unknown: ""
        case .none: "MACH_PORT_NULL"
        default:
            "MACH_MSG_TYPE_"
                + "\(self)"
                .replacingOccurrences(
                    of: "([a-z])([A-Z])", with: "$1_$2", options: .regularExpression
                )
                .uppercased()
        }
    }
}

/// A Mach port with an associated disposition.
public class MachMessagePort: MachPort {
    /// The associated disposition.
    public let disposition: MachPortDisposition

    /// Wrap a given port and associate it with a disposition.
    /// - Parameters:
    ///   - rawPort: The port.
    ///   - disposition: The disposition.
    public init(rawPort: mach_port_t, disposition: MachPortDisposition) {
        self.disposition = disposition
        super.init(rawValue: rawPort)
    }

    @available(*, unavailable)
    public required init(rawValue: mach_port_t) {
        self.disposition = .none
        super.init(rawValue: rawValue)
    }

    @available(*, unavailable)
    public required init(nilLiteral: ()) {
        self.disposition = .none
        super.init(rawValue: TASK_NULL)
    }
}

extension MachPort {
    func withDisposition(_ disposition: MachPortDisposition) -> MachMessagePort {
        MachMessagePort(rawPort: rawValue, disposition: disposition)
    }
}
