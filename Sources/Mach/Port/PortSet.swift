import Darwin.Mach

extension Mach {
    /// A port set.
    public class PortSet: Mach.Port {
        /// The ports in the port set.
        public var ports: [Mach.Port] {
            get throws {
                var namesCount = mach_msg_type_number_t.max
                var names: mach_port_name_array_t? = mach_port_name_array_t.allocate(
                    capacity: Int(namesCount)
                )
                try Mach.call(
                    mach_port_get_set_status(self.name, self.owningTask.name, &names, &namesCount)
                )
                return (0..<Int(namesCount)).map {
                    let port = Mach.Port(named: names![$0])
                    port.owningTask = self.owningTask
                    return port
                }
            }
        }
        /// Insert a port into the port set.
        /// - Parameter port: The port to insert.
        /// - Throws: An error if the port cannot be inserted.
        public func insert(_ port: Mach.Port) throws {
            try Mach.call(
                mach_port_insert_member(self.owningTask.name, port.name, self.name)
            )
        }
    }
}

extension Mach.Port {
    /// Move the port into a port set.
    /// - Parameter set: The port set to move the port into.
    /// - Throws: An error if the port cannot be moved.
    /// - Warning: If the port is already a member of any port sets, it will be removed from them.
    public func move(into set: Mach.PortSet) throws {
        try Mach.call(
            mach_port_move_member(self.owningTask.name, self.name, set.name)
        )
    }
}