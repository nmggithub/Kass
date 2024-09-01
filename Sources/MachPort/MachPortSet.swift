import MachO

/// A set of Mach ports.
open class MachPortSet: MachPortImpl {
    /// A special initializer for a null port.
    /// - Parameter nilLiteral: The nil literal.
    /// - Warning: Do not use this initializer directly. Instead, initialize this class with `nil`.
    public required init(nilLiteral: ()) {
        super.init(rawValue: TASK_READ_NULL)
    }
    /// Wrap a given port set reference.
    /// - Parameter rawValue: The port referencing the port set.
    /// - Warning: The given port must reference a port set. If it does not, this initializer will wrap a null port.
    public required init(rawValue: mach_port_t) {
        // Ensure that the port is a port set.
        guard MachPortImpl.rights(of: rawValue).contains(.portSet) else {
            super.init(nilLiteral: ())
            return
        }
        super.init(rawValue: rawValue)
    }
    @available(*, unavailable, message: "Use `allocate(name:)` instead.")
    override public class func allocate(
        right: Right, name: mach_port_name_t? = nil, in task: MachTask = .current
    ) -> Self {
        guard right == .portSet else { return nil }
        return super.allocate(right: right, name: name, in: task)
    }

    /// Allocate a new Mach port set with an optional name.
    /// - Parameter name: The name to allocate the port set with.
    /// - Returns: The allocated port set.
    public class func allocate(name: mach_port_name_t? = nil) -> Self {
        return super.allocate(right: .portSet, name: name)
    }

    /// The Mach ports in the set.
    /// - Note: Both inserting and removing ports are not guaranteed to succeed. Any errors from the Mach kernel when doing so are ignored.
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
