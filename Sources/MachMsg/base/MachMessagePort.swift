import CCompat
import MachO

/// A Mach port with an associated disposition.
public class MachMessagePort: MachPort {
    /// The disposition of a Mach port.
    public enum Disposition: mach_msg_type_name_t, CBinIntMacroEnum {
        case unknown = 0xFFFF_FFFF
        case none = 0  // MACH_MSG_TYPE_PORT_NONE
        case moveReceive = 16  // MACH_MSG_TYPE_MOVE_RECEIVE
        case moveSend = 17  // MACH_MSG_TYPE_MOVE_SEND
        case moveSendOnce = 18  // MACH_MSG_TYPE_MOVE_SEND_ONCE
        case copySend = 19  // MACH_MSG_TYPE_COPY_SEND
        case makeSend = 20  // MACH_MSG_TYPE_MAKE_SEND
        case makeSendOnce = 21  // MACH_MSG_TYPE_MAKE_SEND_ONCE
        case copyReceive = 22  // MACH_MSG_TYPE_COPY_RECEIVE
        case disposeReceive = 24  // MACH_MSG_TYPE_DISPOSE_RECEIVE
        case disposeSend = 25  // MACH_MSG_TYPE_DISPOSE_SEND
        case disposeSendOnce = 26  // MACH_MSG_TYPE_DISPOSE_SEND_ONCE
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

    /// Initialize a new Mach port.
    /// - Parameters:
    ///   - rawValue: The port.
    ///   - disposition: The disposition of the port.
    public init(rawPort: mach_port_t, disposition: Disposition) {
        self.disposition = disposition
        super.init(rawValue: rawPort)
    }
    /// Initialize a new Mach port with the given raw port.
    public required init(rawValue: mach_port_t) {
        self.disposition = .none
        super.init(rawValue: rawValue)
    }
}
