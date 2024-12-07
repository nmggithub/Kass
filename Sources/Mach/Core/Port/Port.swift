import Darwin.Mach
import Foundation
import KassHelpers

extension Mach {
    /// Flags to use when constructing a port.
    public struct PortConstructFlags: OptionSet, Sendable, KassHelpers.NamedOptionEnum {

        /// The name of the flag, if it can be determined.
        public let name: String?

        /// Represents a flag with an optional name.
        public init(name: String?, rawValue: Int32) {
            self.name = name
            self.rawValue = rawValue
        }

        /// The raw value of the flags.
        public let rawValue: Int32

        /// All known port construction flags.
        public static var allCases: [Self] {
            var allGeneralFlags: [Self] =
                [
                    .contextAsGuard, .queueLimit, .tempOwner, .importanceReceiver, .insertSendRight,
                    .strict, .denapReceiver, .immovableReceive, .filterMsg,
                    .trackThreadGroupBlocking, .servicePort, .connectionPort,
                    .replyPort, .enforceReplyPortSemantics,
                    .provisionalReplyPort,
                ]
            if #available(macOS 15, *) {
                allGeneralFlags.append(.exceptionPort)
            }
            return allGeneralFlags
        }

        /// Use the passed context as a guard.
        public static let contextAsGuard = Self(
            name: "contextAsGuard", rawValue: MPO_CONTEXT_AS_GUARD
        )

        /// Use the passed queue limit.
        public static let queueLimit = Self(name: "queueLimit", rawValue: MPO_QLIMIT)

        /// Set the tempower bit on the port.
        public static let tempOwner = Self(name: "tempOwner", rawValue: MPO_TEMPOWNER)

        /// Mark the port as an importance receiver.
        public static let importanceReceiver = Self(
            name: "importanceReceiver", rawValue: MPO_IMPORTANCE_RECEIVER
        )

        /// Insert a send right in addition to the allocated receive right.
        public static let insertSendRight = Self(
            name: "insertSendRight", rawValue: MPO_INSERT_SEND_RIGHT
        )

        /// Use strict guarding.
        /// - Important: This flag is ignored if the ``contextAsGuard`` flag is not passed.
        public static let strict = Self(name: "strict", rawValue: MPO_STRICT)

        /// Mark the port as a De-Nap receiver.
        public static let denapReceiver = Self(name: "denapReceiver", rawValue: MPO_DENAP_RECEIVER)

        /// Mark the receive right as immovable, protected by the guard.
        /// - Important: This flag is ignored if the ``contextAsGuard`` flag is not passed.
        public static let immovableReceive = Self(
            name: "immovableReceive", rawValue: MPO_IMMOVABLE_RECEIVE
        )

        /// Enable message filtering.
        public static let filterMsg = Self(name: "filterMsg", rawValue: MPO_FILTER_MSG)

        /// Enable tracking of thread group blocking.
        public static let trackThreadGroupBlocking = Self(
            name: "trackThreadGroupBlocking", rawValue: MPO_TG_BLOCK_TRACKING
        )

        /// Construct a service port.
        /// - Important: This is only allowed for the init system.
        public static let servicePort = Self(name: "servicePort", rawValue: MPO_SERVICE_PORT)

        /// Construct a connection port.
        public static let connectionPort = Self(
            name: "connectionPort", rawValue: MPO_CONNECTION_PORT
        )

        /// Mark the port as a reply port.
        public static let replyPort = Self(name: "replyPort", rawValue: MPO_REPLY_PORT)

        /// Enforce reply port semantics.
        ///
        /// When reply port semantics are enforced, messages that are sent to the port
        /// must indicate a reply port as the local port in the message header.
        public static let enforceReplyPortSemantics = Self(
            name: "enforceReplyPortSemantics",
            rawValue: MPO_ENFORCE_REPLY_PORT_SEMANTICS
        )

        /// Mark the port as a provisional reply port.
        public static let provisionalReplyPort = Self(
            name: "provisionalReplyPort",
            rawValue: MPO_PROVISIONAL_REPLY_PORT
        )

        /// Mark the port as an exception port.
        @available(macOS, introduced: 15)
        // There was briefly an flag with the name `MPO_PROVISIONAL_ID_PROT_OPTOUT` that had
        // the same value as this flag now has. It didn't appear to actually do anything. It
        // is no longer in the header files and has been replaced with this flag, which does
        // seem to do something. The previous flag will not be included in this library.
        public static let exceptionPort = Self(
            name: "exceptionPort",
            rawValue: MPO_EXCEPTION_PORT
        )
    }
}

extension Mach {
    /// A right to a port.
    public struct PortRights: OptionSet, KassHelpers.NamedOptionEnum, Hashable {
        /// The name of the port right, if it can be determined.
        public let name: String?

        /// Represents a port right with an optional name.
        public init(name: String?, rawValue: mach_port_right_t) {
            self.name = name
            self.rawValue = rawValue
        }

        /// The raw value of the port right.
        public let rawValue: mach_port_right_t

        public static var allCases: [Mach.PortRights] {
            [.send, .receive, .sendOnce, .portSet, .deadName]
        }

        /// The individual rights in the set.
        public var rights: [Mach.PortRights] {
            Mach.PortRights.allCases.filter { contains($0) }
        }

        /// A right to send messages to a port.
        public static let send = Self(name: "send", rawValue: MACH_PORT_RIGHT_SEND)

        /// A right to receive messages from a port.
        public static let receive = Self(name: "receive", rawValue: MACH_PORT_RIGHT_RECEIVE)

        /// A right to send messages to a port once.
        public static let sendOnce = Self(name: "sendOnce", rawValue: MACH_PORT_RIGHT_SEND_ONCE)

        /// A special right to manage a collection of ports (a port set).
        public static let portSet = Self(name: "portSet", rawValue: MACH_PORT_RIGHT_PORT_SET)

        /// A special right that is named by a dead name.
        public static let deadName = Self(name: "deadName", rawValue: MACH_PORT_RIGHT_DEAD_NAME)
    }

    /// A port ``name`` in the ``owningTask``'s name space.
    open class Port {
        /// A nil-named port.
        open class var Nil: Port { Port(named: mach_port_name_t(MACH_PORT_NULL)) }

        /// The name of the port in the ``owningTask``'s name space.
        public let name: mach_port_name_t

        /// The raw task that the port name is in the name space of.
        private let rawOwningTask: task_t

        /// The task that the port ``name`` is in the name space of.
        public var owningTask: Mach.Task {
            Task(named: self.rawOwningTask, inNameSpaceOf: .current)
        }

        /// The port rights named by ``Port/name``.
        public var rights: Mach.PortRights {
            get throws {
                var type = mach_port_type_t()
                try Mach.call(mach_port_type(self.owningTask.name, self.name, &type))
                var rights: Mach.PortRights = []
                for right in Mach.PortRights.allCases {
                    // `mach_port_type_t` is a bitfield for the rights
                    if type & 1 << (right.rawValue + 16) != 0 {
                        rights.insert(right)
                    }
                }
                return rights
            }
        }

        /// References an existing port.
        public required init(named name: mach_port_name_t, inNameSpaceOf task: Task = .current) {
            self.name = name
            self.rawOwningTask = task.name
        }

        /// References an existing port.
        /// - Note: This is really only here to give ``Mach/Task/current`` an
        ///  initialization path that doesn't end in an infinite loop.
        /// - Note: This is declared after the above initializer so that the one above will
        /// hopefully take precedence in cases where `init(named:)` is used. If this didn't
        /// happen and we used `init(named:)` in a public function or property accessor, it
        /// would lead to a linking error in consumers of this library. It appears that the
        /// Swift compiler isn't smart enough to realize this and won't warn us. Generally,
        /// we should avoid uses of `init(named:)` internally and instead fully qualify our
        /// usage of initializers for ``Mach/Port`` and its subclasses.
        internal init(named name: mach_port_name_t, inNameSpaceOf task: task_t) {
            self.name = name
            self.rawOwningTask = task
        }

        /// Destroys the port.
        /// - Warning: This is an inherently unsafe API.
        @available(
            macOS, deprecated: 12.0,
            // This message is copied from the deprecation message for `mach_port_destroy`
            // and modified to refer to this library's API.
            message: """
                Inherently unsafe API: instead manage rights with
                destruct(guard:sendRightDelta:), deallocate() or userRefs(for:).
                """
        )
        open func destroy() throws {
            try Mach.call(mach_port_destroy(self.owningTask.name, self.name))
        }
    }
}

extension Mach.Port {
    /// The kernel object underlying the port.
    public var kernelObject: Mach.KernelObject {
        get throws {
            try Mach.KernelObject(underlying: self)
        }
    }
}

extension Mach.Port: Equatable {
    /// Compares two ports.
    public static func == (lhs: Mach.Port, rhs: Mach.Port) -> Bool {
        return lhs.name == rhs.name && lhs.rawOwningTask == rhs.rawOwningTask
    }

    /// Compares a port to a port name.
    public static func == (lhs: Mach.Port, rhs: mach_port_name_t) -> Bool {
        return lhs.name == rhs
    }

    /// Compares a port name to a port.
    public static func == (lhs: mach_port_name_t, rhs: Mach.Port) -> Bool {
        return lhs == rhs.name
    }

    /// Compares two ports.
    public static func != (lhs: Mach.Port, rhs: Mach.Port) -> Bool {
        return !(lhs == rhs)
    }
}

extension Mach.Port {
    /// Gets the context of the port.
    public func getContext() throws -> mach_port_context_t {
        var context = mach_port_context_t()
        try Mach.call(mach_port_get_context(self.owningTask.name, self.name, &context))
        return context
    }

    /// Sets the context of the port.
    public func setContext(to context: mach_port_context_t) throws {
        try Mach.call(mach_port_set_context(self.owningTask.name, self.name, context))
    }

    /// The context of the port.
    /// - Note: This is an alternative to the ``Port/setContext(to:)`` function.
    public var context: mach_port_context_t {
        get throws {
            return try self.getContext()
        }
    }
}

extension Mach.Port {
    /// The number of send rights the receive right has.
    /// - Important: This port name must name a receive right.
    public var sendRightCount: Int {
        get throws {
            var count = mach_port_right_t()
            try Mach.call(mach_port_get_srights(self.owningTask.name, self.name, &count))
            return Int(count)
        }
    }
}

extension Mach.Port {
    /// Set the make-send count of the port.
    public func setMakeSendCount(to count: Int32) throws {
        try Mach.call(
            mach_port_set_mscount(self.owningTask.name, self.name, mach_port_mscount_t(count))
        )
    }
}

extension Mach {
    /// Flags to guard a port with.
    public struct PortGuardFlags: OptionSet, Sendable {
        public let rawValue: Int32
        public init(rawValue: Int32) { self.rawValue = rawValue }

        public static let strict = Self(rawValue: MPG_STRICT)
        public static let immovableReceive = Self(rawValue: MPG_IMMOVABLE_RECEIVE)
    }
}

extension Mach.Port {

    /// Guards the port using the specified context and flags.
    public func `guard`(
        with context: mach_port_context_t, flags: Mach.PortGuardFlags = []
    ) throws {
        try Mach.call(
            mach_port_guard_with_flags(
                self.owningTask.name, self.name, context, UInt64(flags.rawValue)
            )
        )
    }

    /// Unguards the port using the specified context.
    public func unguard(with context: mach_port_context_t) throws {
        try Mach.call(mach_port_unguard(self.owningTask.name, self.name, context))
    }

    /// ***Experimental.*** Whether the port is guarded.
    /// - Warning: This property being `false` doesn't mean that the port was determined *to not
    /// be guarded*. Instead, it means that it was *not* determined *to be guarded*. However, it
    /// being `true` means that the port was determined *to be guarded*.
    /// - Warning: There is no atomic way to check if a port is guarded. This property relies on
    /// a multi-step process to determine if the port is guarded. If a step fails and leaves the
    /// port in an indeterminate state, this property will crash the program.
    public var guarded: Bool {
        // There is no way to check if a port is guarded without attempting to guard it.
        let testGuard = mach_port_context_t(arc4random())
        do { try self.guard(with: testGuard, flags: []) }  // Attempting to guard the port is the only way to see if it's guarded.
        // Since the `guard` function only calls `mach_port_guard_with_flags`, we assume any caught errors are from
        // that call. We can use the XNU source code to determine what each return code means in this context.
        catch MachError.invalidArgument { return true }  // The port is already guarded.
        catch MachError.invalidName { return false }  // The port doesn't exist.
        catch MachError.invalidTask { return false }  // The port's owning task doesn't exist.
        catch MachError.invalidRight { return false }  // The port doesn't have the correct rights to be guarded.
        catch { fatalError("Unexpected error when guarding the port: \(error)") }  // There was some other error.
        do { try self.unguard(with: testGuard) }  // The guarding worked, so we need to unguard it.
        catch { fatalError("Failed to unguard the port: \(error)") }  // If we can't unguard it, we have a problem.
        return false  // We successfully unguarded the port, so now we know it isn't guarded.
    }
}

extension Mach.Port: Hashable {
    /// Hashes the port.
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.name)
        hasher.combine(self.owningTask)
    }
}

extension Mach.Port: CustomStringConvertible {
    /// A description of the port.
    public var description: String {
        let className = String(describing: Self.self)
        let formattedName = String(format: "0x%08x", self.name)
        return "<Mach.Port(\(className)): name: \(formattedName)>"
    }
}

extension Mach.Port: CustomDebugStringConvertible {
    /// A debug description of the port.
    public var debugDescription: String {
        let formattedName = String(format: "0x%08x", self.name)
        let formattedTask = String(format: "0x%08x", self.rawOwningTask)
        let className = String(describing: Self.self)
        return "<Mach.Port(\(className)): name: \(formattedName), task: \(formattedTask)>"
    }
}
