import CCompat
import MachO
import MachPort

/// A guarded port descriptor.
public struct GuardedPortDescriptor: MachMessageDescriptor {
    public typealias CStruct = mach_msg_guarded_port_descriptor_t
    /// The raw guarded port descriptor.
    public var rawValue: mach_msg_guarded_port_descriptor_t {
        mach_msg_guarded_port_descriptor_t(
            context: self.context,
            flags: self.guardFlags.rawValue,
            disposition: disposition?.rawValue ?? 0,
            type: DescriptorType.guardedPort.rawValue,
            name: self.port.rawValue
        )
    }
    /// The port.
    public var port: MachPort
    /// The disposition.
    public var disposition: MachPortDisposition?
    /// The context.
    public var context: mach_port_context_t
    /// A guard flag.
    public enum GuardFlag: mach_msg_guard_flags_t, COptionMacroEnum {
        case none = 0
        case immovableReceive = 1
        case unguardedOnSend = 2
        public var cMacroName: String {
            "MACH_MSG_GUARD_FLAGS_"
                + "\(self)".replacingOccurrences(
                    of: "([a-z])([A-Z])", with: "$1_$2", options: .regularExpression
                )
                .uppercased()
        }
    }

    /// A set of guard flags.
    public typealias GuardFlags = COptionMacroSet<GuardFlag>
    /// The guard flags.
    public var guardFlags: GuardFlags
    /// Represent an existing raw guarded port descriptor.
    /// - Parameter rawValue: The raw guarded port descriptor.
    public init(rawValue: mach_msg_guarded_port_descriptor_t) {
        self.port = .init(rawValue: rawValue.name)
        self.disposition = .init(rawValue: rawValue.disposition)
        self.context = rawValue.context
        self.guardFlags = GuardFlags(rawValue: rawValue.flags) ?? []
    }
    /// Create a new guarded port descriptor.
    public init() {
        self.port = nil
        self.disposition = nil
        self.context = 0
        self.guardFlags = []
    }
    /// Create a new guarded port descriptor with a port.
    /// - Parameters:
    ///   - port: The port.
    ///   - disposition: The disposition.
    ///   - context: The context.
    ///   - guardFlags: The guard flags.
    public init(
        _ port: MachPort, disposition: MachPortDisposition? = nil,
        context: mach_port_context_t = 0, guardFlags: GuardFlags = []
    ) {
        self.port = port
        self.disposition = disposition
        self.context = context
        self.guardFlags = guardFlags
    }
}
