import CCompat
import Darwin.Mach
import Foundation

extension Mach {
    /// A right to a port.
    public enum PortRight: mach_port_right_t, CaseIterable {
        /// A right to send messages to a port.
        case send = 0

        /// A right to receive messages from a port.
        case receive = 1

        /// A right to send messages to a port once.
        case sendOnce = 2

        /// A special right to manage a collection of ports (a port set).
        case portSet = 3

        /// A special right that is named by a dead name.
        case deadName = 4
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
        public var rights: Set<Mach.PortRight> {
            get throws {
                var type = mach_port_type_t()
                try Mach.call(mach_port_type(self.owningTask.name, self.name, &type))
                var rights = Set<Mach.PortRight>()
                for right in Mach.PortRight.allCases {
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

        /// Allocates a new port with a given right in the specified task with an optional name.
        public init(
            right: Mach.PortRight, named name: mach_port_name_t? = nil,
            inNameSpaceOf task: Mach.Task = .current
        ) throws {
            var generatedPortName = mach_port_name_t()
            try Mach.call(
                name != nil
                    ? mach_port_allocate_name(task.name, right.rawValue, name!)
                    : mach_port_allocate(task.name, right.rawValue, &generatedPortName)
            )
            self.name = name ?? generatedPortName
            self.rawOwningTask = task.name
        }

        /// Deallocates the port.
        public func deallocate() throws {
            try Mach.call(mach_port_deallocate(self.owningTask.name, self.name))
        }

        /// A flag to use when constructing a port.
        public enum ConstructFlag: UInt32 {
            /// Use the passed context as a guard.
            case contextAsGuard = 0x01

            /// Use the passed queue limit.
            case queueLimit = 0x02

            /// Set the tempower bit on the port.
            case tempOwner = 0x04

            /// Mark the port as an importance receiver.
            case importanceReceiver = 0x08

            /// Insert a send right in addition to the allocated receive right.
            case insertSendRight = 0x10

            /// Use strict guarding.
            /// - Important: This flag is ignored if the ``contextAsGuard`` flag is not passed.
            case strict = 0x20

            /// Mark the port as a De-Nap receiver.
            case denapReceiver = 0x40

            /// Mark the receive right as immovable, protected by the guard.
            /// - Important: This flag is ignored if the ``contextAsGuard`` flag is not passed.
            case immovableReceive = 0x80

            /// Enable message filtering.
            case filterMsg = 0x100

            /// Enable tracking of thread group blocking.
            case trackThreadGroupBlocking = 0x200

            /// Construct a service port.
            /// - Important: This is only allowed for the init system.
            case servicePort = 0x400

            /// Construct a connection port.
            case connectionPort = 0x800

            /// Mark the port as a reply port.
            case replyPort = 0x1000

            /// Enforce reply port semantics.
            ///
            /// When reply port semantics are enforced, messages that are sent to the port
            ///  must indicate a reply port as the local port in the message header.
            case enforceReplyPortSemantics = 0x2000

            /// Mark the port as a provisional reply port.
            case provisionalReplyPort = 0x4000

            /// Opt out of identity protection for the port.
            case provisionalIdProtOutput = 0x8000
        }

        /// Constructs a new port with the given options.
        public init(
            options: consuming mach_port_options_t,
            context: mach_port_context_t? = nil,
            inNameSpaceOf task: Mach.Task = .current
        ) throws {
            var generatedPortName = mach_port_name_t()
            if context != nil {
                // We enforce adding this flag if a context is passed, even if the user didn't
                // specify it. The context is ignored otherwise.
                options.flags |= ConstructFlag.contextAsGuard.rawValue
            }
            if options.mpl.mpl_qlimit != 0 {
                // We enforce adding this flag is a limit is passed, even if the user didn't
                // specify it. The limit is ignored otherwise.
                options.flags |= ConstructFlag.queueLimit.rawValue
            }
            let actualContext = context ?? mach_port_context_t()
            try Mach.call(
                mach_port_construct(task.name, &options, actualContext, &generatedPortName)
            )
            self.name = generatedPortName
            self.rawOwningTask = task.name
        }

        /// Constructs a new port with the given flags and limits.
        public convenience init(
            flags: Set<ConstructFlag>, limits: mach_port_limits = mach_port_limits(),
            inNameSpaceOf task: Mach.Task = .current
        ) throws {
            var options = mach_port_options_t()
            options.flags = flags.bitmap()
            options.mpl = limits
            try self.init(options: options, context: nil, inNameSpaceOf: task)
        }

        /// Destructs the port.
        /// - Parameters:
        ///   - guard: The context to unguard the port with.
        ///   - sendRightDelta: The delta to apply to the send right user reference count.
        /// - Throws: If the port cannot be destructed.
        public func destruct(
            guard: mach_port_context_t = mach_port_context_t(), sendRightDelta: mach_port_delta_t
        ) throws {
            try Mach.call(
                mach_port_destruct(self.owningTask.name, self.name, sendRightDelta, `guard`)
            )
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
    public func setContext(_ context: mach_port_context_t) throws {
        try Mach.call(mach_port_set_context(self.owningTask.name, self.name, context))
    }

    /// The context of the port.
    /// - Note: This is an alternative to the ``Port/setContext(_:)`` function.
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
    public func setMakeSendCount(_ count: Int32) throws {
        try Mach.call(
            mach_port_set_mscount(self.owningTask.name, self.name, mach_port_mscount_t(count))
        )
    }
}

extension Mach.Port {
    /// A flag to guard a port with.
    public enum GuardFlag: UInt64 {
        case strict = 1
        case immovableReceive = 2
    }

    /// Guards the port with the specified context and flags.
    public func `guard`(
        _ context: mach_port_context_t, flags: Set<Mach.Port.GuardFlag> = []
    ) throws {
        try Mach.call(
            mach_port_guard_with_flags(
                self.owningTask.name, self.name, context, flags.bitmap()
            )
        )
    }

    /// Unguards the port with the specified context.
    public func unguard(_ context: mach_port_context_t) throws {
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
        do { try self.guard(testGuard, flags: []) }  // Attempting to guard the port is the only way to see if it's guarded.
        // Since the `guard` function only calls `mach_port_guard_with_flags`, we assume any caught errors are from
        // that call. We can use the XNU source code to determine what each return code means in this context.
        catch MachError.invalidArgument { return true }  // The port is already guarded.
        catch MachError.invalidName { return false }  // The port doesn't exist.
        catch MachError.invalidTask { return false }  // The port's owning task doesn't exist.
        catch MachError.invalidRight { return false }  // The port doesn't have the correct rights to be guarded.
        catch { fatalError("Unexpected error when guarding the port: \(error)") }  // There was some other error.
        do { try self.unguard(testGuard) }  // The guarding worked, so we need to unguard it.
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