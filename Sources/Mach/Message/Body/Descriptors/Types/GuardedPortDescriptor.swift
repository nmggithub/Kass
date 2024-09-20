import CCompat
import Darwin.Mach

extension Mach.Message.Body.Descriptor {
    /// A guarded port descriptor.
    public typealias GuardedPort = Mach.Message.Body.GuardedPortDescriptor
}

extension Mach.Message.Body {
    /// A guarded port descriptor.
    public struct GuardedPortDescriptor: Descriptor {
        public typealias CStruct = mach_msg_guarded_port_descriptor_t
        /// The raw guarded port descriptor.
        public var rawValue: mach_msg_guarded_port_descriptor_t {
            mach_msg_guarded_port_descriptor_t(
                context: self.context,
                flags: self.guardFlags.bitmap(),
                disposition: disposition?.rawValue ?? 0,
                type: DescriptorType.guardedPort.rawValue,
                name: self.port.name
            )
        }
        /// The port.
        public var port: Mach.Port
        /// The disposition.
        public var disposition: Mach.Port.Disposition?
        /// The context.
        public var context: mach_port_context_t
        /// A guard flag.
        public enum GuardFlag: mach_msg_guard_flags_t {
            case none = 0
            case immovableReceive = 1
            case unguardedOnSend = 2
        }

        /// A set of guard flags.
        public typealias GuardFlags = Set<GuardFlag>
        /// The guard flags.
        public var guardFlags: GuardFlags
        /// Represents an existing raw guarded port descriptor.
        /// - Parameter rawValue: The raw guarded port descriptor.
        public init(rawValue: mach_msg_guarded_port_descriptor_t) {
            self.port = .init(named: rawValue.name)
            self.disposition = .init(rawValue: rawValue.disposition)
            self.context = rawValue.context
            self.guardFlags = []  // GuardFlags(rawValue: rawValue.flags) ?? []
        }
        /// Creates a new guarded port descriptor.
        public init() {
            self.port = .init(named: mach_port_t(MACH_PORT_NULL))
            self.disposition = nil
            self.context = 0
            self.guardFlags = []
        }
        /// Creates a new guarded port descriptor with a port.
        /// - Parameters:
        ///   - port: The port.
        ///   - disposition: The disposition.
        ///   - context: The context.
        ///   - guardFlags: The guard flags.
        public init(
            _ port: Mach.Port, disposition: Mach.Port.Disposition? = nil,
            context: mach_port_context_t = 0, guardFlags: GuardFlags = []
        ) {
            self.port = port
            self.disposition = disposition
            self.context = context
            self.guardFlags = guardFlags
        }
    }
}
