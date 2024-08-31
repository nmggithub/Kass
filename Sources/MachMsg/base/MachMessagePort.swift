import CCompat
import MachO
import MachPort

/// A wrapper for a Mach port with an associated disposition.
public class MachMessagePort: MachPort {
    /// A special initializer for a null port.
    /// - Parameter nilLiteral: The nil literal.
    /// - Warning: Do not use this initializer directly. Instead, initialize this class with `nil`.
    public required init(nilLiteral: ()) {
        self.disposition = .none
        super.init(rawValue: TASK_NULL)
    }
    /// A disposition of a Mach port.
    public enum Disposition: mach_msg_type_name_t, CBinIntMacroEnum {
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
            "MACH_MSG_TYPE_"
                + "\(self)"
                .replacingOccurrences(
                    of: "([a-z])([A-Z])", with: "$1_$2", options: .regularExpression
                )
                .uppercased()
        }
    }
    /// The disposition of the port.
    public let disposition: Disposition

    /// Wrap a given port and associate it with a disposition.
    /// - Parameters:
    ///   - rawPort: The port.
    ///   - disposition: The disposition of the port.
    public init(rawPort: mach_port_t, disposition: Disposition) {
        self.disposition = disposition
        super.init(rawValue: rawPort)
    }

    @available(*, unavailable)  // This initializer required, but we don't want it to be used.
    public required init(rawValue: mach_port_t) {
        self.disposition = .none
        super.init(rawValue: rawValue)
    }
}
