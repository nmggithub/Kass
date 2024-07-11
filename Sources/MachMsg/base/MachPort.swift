import CCompat
import Darwin

/// A Mach port.
public struct MachPort {
    /// The disposition of a Mach port.
    public enum Disposition: mach_msg_type_name_t, NameableByCMacro {
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
    /// The port.
    public let port: mach_port_t
    /// The disposition of the port.
    public let disposition: Disposition
    /// Initialize a new Mach port.
    public init() {
        self.init(port: mach_port_t(MACH_PORT_NULL), disposition: .none)
    }
    /// Initialize a new Mach port.
    /// - Parameters:
    ///   - port: The port.
    ///   - disposition: The disposition of the port.
    public init(port: mach_port_t, disposition: Disposition) {
        self.port = port
        self.disposition = disposition
    }
}
