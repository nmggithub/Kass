import Darwin

/// A set of Mach ports.
class MachPortSet: MachPort {
    /// Initialize a Mach port set with the given raw port.
    /// - Parameter rawValue: The port.
    required init(rawValue: mach_port_t) {
        // Ensure that the port is a port set.
        guard MachPort.rights(of: rawValue).contains(.portSet) else {
            super.init(rawValue: mach_port_t(MACH_PORT_NULL))
            return
        }
        super.init(rawValue: rawValue)
    }

    /// Allocate a new Mach port set with the given right (and optionally a name).
    /// - Parameters:
    ///   - right: The right to allocate the port set with.
    ///   - name: The name to allocate the port set with.
    /// - Returns: The allocated port set.
    /// - Warning: The right must be `.portSet`. Otherwise, a null port will be returned. For an easier way to allocate a port set, use `allocate(name:)`.
    override public class func allocate(right: Right, name: mach_port_name_t? = nil) -> Self {
        guard right == .portSet else { return Self.null }
        return super.allocate(right: right, name: name)
    }

    /// Allocate a new Mach port set with an optional name.
    /// - Parameter name: The name to allocate the port set with.
    /// - Returns: The allocated port set.
    public class func allocate(name: mach_port_name_t? = nil) -> Self {
        return super.allocate(right: .portSet, name: name)
    }

    /// The Mach ports in the set.
    /// - Warning: Adding or removing a port from this set will also remove it from any other sets it is in.
    public var ports: Set<MachPort> {
        get {
            var namesCount = mach_msg_type_number_t.max
            var names: mach_port_name_array_t? = mach_port_name_array_t.allocate(
                capacity: Int(namesCount)
            )
            let ret = mach_port_get_set_status(mach_task_self_, self.rawValue, &names, &namesCount)
            guard ret == KERN_SUCCESS else { return [] }
            return Set((0..<Int(namesCount)).map { MachPort(rawValue: names![$0]) })
        }
        set {
            let newPorts = newValue.subtracting(self.ports)
            let oldPorts = self.ports.subtracting(newValue)
            for newPort in newPorts {
                mach_port_move_member(mach_task_self_, newPort.rawValue, self.rawValue)
            }
            for oldPort in oldPorts {
                mach_port_move_member(
                    mach_task_self_, oldPort.rawValue, mach_port_t(MACH_PORT_NULL)
                )
            }
        }
    }
}
