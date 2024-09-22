@preconcurrency import Darwin.Mach
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
        open class var Nil: Self {
            return Self(named: mach_port_name_t(MACH_PORT_NULL))
        }
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

        /// The raw task that the port name is in the namespace of.
        private var rawOwningTask: task_t = mach_task_self_

        /// The name of the port in the ``Port/owningTask``'s namespace.
        public let name: mach_port_name_t

        /// The task that the port name is in the namespace of.
        public var owningTask: Mach.Task {
            // This parameter is computed to avoid an infinite initialization loop
            // when initializing a `Task`, which is itself a `Port`.
            get {
                return Task(named: self.rawOwningTask)
            }
            set {
                self.rawOwningTask = newValue.name
            }
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

        /// References an existing port in the current task's namespace.
        /// - Parameters:
        ///   - name: The name of the port.
        public required init(named name: mach_port_name_t) {
            self.name = name
        }

        /// References an existing port in a given task's namespace.
        /// - Parameters:
        ///   - name: The name of the port.
        ///   - task: The task that the port is in the namespace of.
        public convenience init(named name: mach_port_name_t, in task: Task) {
            self.init(named: name)
            self.owningTask = task
        }
    }
}
