import CCompat
@preconcurrency import Darwin.Mach
import Foundation
@_exported import MachBase

extension Mach {
    /// A port name in a task's namespace.
    open class Port: Equatable, Hashable, CustomStringConvertible {
        /// A description of the port.
        public var description: String {
            let formattedName = String(format: "0x%08x", self.name)
            let formattedTask = String(format: "0x%08x", self.rawOwningTask)
            let className = String(describing: Self.self)
            return "<Mach.Port(\(className)): name: \(formattedName), task: \(formattedTask)>"
        }

        /// Hashes the port.
        /// - Parameter hasher: The hasher to use.
        public func hash(into hasher: inout Hasher) {
            hasher.combine(self.name)
            hasher.combine(self.owningTask)
        }

        /// A nil-named port.
        open class var Nil: Port { Port(named: mach_port_name_t(MACH_PORT_NULL)) }

        /// A right to a port.
        public enum Right: mach_port_right_t, CaseIterable {
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

        /// Compares two ports.
        /// - Parameters:
        ///   - lhs: The port on the left-hand side of the comparison.
        ///   - rhs: The port on the right-hand side of the comparison.
        /// - Returns: Whether the two ports are equal.
        public static func == (lhs: Mach.Port, rhs: Mach.Port) -> Bool {
            return lhs.name == rhs.name && lhs.owningTask == rhs.owningTask
        }

        /// Compares a port to a port name.
        /// - Parameters:
        ///   - lhs: The port (on the left-hand side of the comparison).
        ///   - rhs: The port name (on the right-hand side of the comparison).
        /// - Returns: Whether the port's name is equal to the port name.
        public static func == (lhs: Mach.Port, rhs: mach_port_name_t) -> Bool {
            return lhs.name == rhs
        }

        /// Compares a port name to a port.
        /// - Parameters:
        ///   - lhs: The port name (on the left-hand side of the comparison).
        ///   - rhs: The port (on the right-hand side of the comparison).
        /// - Returns: Whether the port name is equal to the port's name.
        public static func == (lhs: mach_port_name_t, rhs: Mach.Port) -> Bool {
            return lhs == rhs.name
        }

        /// Compares two ports.
        /// - Parameters:
        ///   - lhs: The port on the left-hand side of the comparison.
        ///   - rhs: The port on the right-hand side of the comparison.
        /// - Returns: Whether the two ports are not equal.
        public static func != (lhs: Mach.Port, rhs: Mach.Port) -> Bool {
            return !(lhs == rhs)
        }

        /// The name of the port in the ``Port/owningTask``'s namespace.
        public let name: mach_port_name_t

        /// The raw task that the port name is in the namespace of.
        private var rawOwningTask: task_t = mach_task_self_

        /// The task that the port name is in the namespace of.
        public var owningTask: Mach.Task {
            // This parameter is computed to avoid an infinite initialization loop
            // when initializing a `Task`, which is itself a `Port`.
            get { return Task(named: self.rawOwningTask) }
            set { self.rawOwningTask = newValue.name }
        }

        /// Gets the context of the port.
        /// - Throws: If the context cannot be retrieved.
        /// - Returns: The context of the port.
        public func getContext() throws -> mach_port_context_t {
            var context = mach_port_context_t()
            try Mach.call(mach_port_get_context(self.owningTask.name, self.name, &context))
            return context
        }

        /// Sets the context of the port.
        /// - Parameter context: The context to set.
        /// - Throws: If the context cannot be set.
        public func setContext(_ context: mach_port_context_t) throws {
            try Mach.call(mach_port_set_context(self.owningTask.name, self.name, context))
        }

        /// The context of the port.
        /// - Throws: If the context cannot be retrieved.
        /// - Note: This is an alternative to the ``Port/setContext(_:)`` function.
        public var context: mach_port_context_t {
            get throws {
                return try self.getContext()
            }
        }
        /// The port rights named by ``Port/name``.
        public var rights: Set<Right> {
            var type = mach_port_type_t()
            do {
                try Mach.call(mach_port_type(self.owningTask.name, self.name, &type))
            } catch { return [] }
            var rights = Set<Right>()
            for right in Right.allCases {
                // `mach_port_type_t` is a bitfield for the rights
                if type & 1 << (right.rawValue + 16) != 0 {
                    rights.insert(right)
                }
            }
            return rights
        }

        /// References an existing port in a given task's namespace.
        /// - Parameters:
        ///   - name: The name of the port.
        ///   - task: The task that the port is in the namespace of.
        public required init(named name: mach_port_name_t, in task: Task = .current) {
            self.name = name
            self.owningTask = task
        }

        /// References an existing port in the current task's namespace.
        /// - Parameters:
        ///   - name: The name of the port.
        init(named name: mach_port_name_t) {
            self.name = name
        }

        @available(
            macOS, deprecated: 12.0,
            message: "This API is marked as deprecated as of macOS 12.0."
        )
        /// Destroys the port.
        /// - Warning: This is an inherently unsafe API.
        open func destroy() throws {
            try Mach.call(mach_port_destroy(self.owningTask.name, self.name))
        }

        /// Allocates a new port with a given right in the specified task with an optional name.
        /// - Parameters:
        ///   - right: The right to allocate.
        ///   - name: The name to assign to the port.
        ///   - task: The task to allocate the port in.
        /// - Important: Only the ``Right/receive``, ``Right/portSet``, and ``Right/deadName`` rights
        /// are valid for port allocation.
        public init(
            right: Right, named name: mach_port_name_t? = nil, in task: Mach.Task = .current
        ) throws {
            var generatedPortName = mach_port_name_t()
            try Mach.call(
                name != nil
                    ? mach_port_allocate_name(task.name, right.rawValue, name!)
                    : mach_port_allocate(task.name, right.rawValue, &generatedPortName)
            )
            self.name = name ?? generatedPortName
        }

        /// Deallocates the port.
        public func deallocate() throws {
            try Mach.call(mach_port_deallocate(self.owningTask.name, self.name))
        }

        /// A flag to use when constructing a port.
        public enum ConstructFlag: UInt32 {
            case contextAsGuard = 0x01
            case queueLimit = 0x02
            case tempOwner = 0x04
            case importanceReceiver = 0x08
            case insertSendRight = 0x10
            case strict = 0x20
            case denapReceiver = 0x40
            case immovableReceive = 0x80
            case filterMsg = 0x100
            case tgBlockTracking = 0x200
            case servicePort = 0x400
            case connectionPort = 0x800
            case replyPort = 0x1000
            case replyPortSemantics = 0x2000
            case provisionalReplyPort = 0x4000
            case provisionalIdProtOutput = 0x8000
        }
        /// Constructs a new port with the given options.
        /// - Parameters:
        ///   - queueLimit: The maximum number of messages that can be queued.
        ///   - flags: The flags to use when constructing the port.
        ///   - context: The context to associate with the port.
        ///   - task: The task to construct the port in.
        /// - Important: The `context` parameter is only used to guard the port (and only if the
        /// ``ConstructFlag/contextAsGuard`` flag is passed).
        public init(
            queueLimit: mach_port_msgcount_t, flags: Set<ConstructFlag>,
            context: mach_port_context_t = mach_port_context_t(),
            in task: Mach.Task = .current
        ) throws {
            var generatedPortName = mach_port_name_t()
            var options = mach_port_options_t()
            options.mpl.mpl_qlimit = queueLimit
            options.flags = flags.bitmap()
            try Mach.call(mach_port_construct(task.name, &options, context, &generatedPortName))
            self.name = generatedPortName
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
        /// A flag to guard a port with.
        public enum GuardFlag: UInt64 {
            case strict = 1
            case immovableReceive = 2
        }
        /// Guards the port with the specified context and flags.
        /// - Parameters:
        ///   - context: The context to guard the port with.
        ///   - flags: The flags to guard the port with.
        /// - Throws: An error if the operation fails.
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
        /// - Parameter context: The context to unguard the port with.
        /// - Throws: An error if the operation fails.
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
            // Since the `guard` function only calls `mach_port_guard_with_flags`, we assume any caught errors are from that call. While
            // each of these errors are a bit cryptic, we can use the XNU sources to determine what they mean in this context.
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

}
