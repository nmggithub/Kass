import MachO

/// A set of ports.
open class MachPortSet: MachPortImpl {
    /// A special initializer for a null port.
    /// - Parameter nilLiteral: The nil literal.
    /// - Warning: Do not use this initializer directly. Instead, initialize this class with `nil`.
    public required init(nilLiteral: ()) {
        super.init(rawValue: TASK_READ_NULL)
    }
    /// Represent an existing raw port set.
    /// - Parameter rawValue: The raw port set.
    /// - Warning: The given port must contain the ``MachPortRight/portSet`` right. If it does not, this initializer will return a null port.
    public required init(rawValue: mach_port_t) {
        // Ensure that the port is a port set.
        guard MachPortImpl.rights(of: rawValue).contains(.portSet) else {
            super.init(nilLiteral: ())
            return
        }
        super.init(rawValue: rawValue)
    }
    @available(*, unavailable, message: "Use `allocate(name:)` instead.")
    override public init?(
        right: Right, name: mach_port_name_t? = nil, in task: MachTask = .current
    ) {
        guard right == .portSet else { return nil }
        super.init(right: right, name: name, in: task)
    }

    /// Allocate a new port set with an optional name.
    /// - Parameter name: The name to allocate the port set with.
    /// - Returns: The allocated port set.
    public init?(name: mach_port_name_t? = nil) {
        super.init(right: .portSet, name: name)
    }

    /// The ports in the set.
    /// - Note: Both inserting and removing ports are not guaranteed to succeed. Any errors from the kernel when doing so are ignored.
    /// - Warning: Removing a port from this set will also remove it from any other sets it is in.
    public var ports: Set<MachPortImpl> {
        get {
            var namesCount = mach_msg_type_number_t.max
            var names: mach_port_name_array_t? = mach_port_name_array_t.allocate(
                capacity: Int(namesCount)
            )
            let ret = mach_port_get_set_status(
                self.task.rawValue, self.rawValue, &names, &namesCount)
            guard ret == KERN_SUCCESS else { return [] }
            return Set((0..<Int(namesCount)).map { MachPortImpl(rawValue: names![$0]) })
        }
        set {
            let newPorts = newValue.subtracting(self.ports)
            let oldPorts = self.ports.subtracting(newValue)
            for newPort in newPorts {
                mach_port_insert_member(self.task.rawValue, newPort.rawValue, self.rawValue)
            }
            for oldPort in oldPorts {
                mach_port_move_member(
                    self.task.rawValue, oldPort.rawValue, mach_port_t(MACH_PORT_NULL)
                )
            }
        }
    }
}
