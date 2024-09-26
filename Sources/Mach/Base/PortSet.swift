import Darwin.Mach

extension Mach {
    /// A port set.
    public class PortSet: Mach.Port {
        /// The ports in the port set.
        public var ports: Set<Mach.Port> {
            get throws {
                var namesCount = mach_msg_type_number_t.max
                var names: mach_port_name_array_t? = mach_port_name_array_t.allocate(
                    capacity: Int(namesCount)
                )
                try Mach.call(
                    mach_port_get_set_status(self.name, self.owningTask.name, &names, &namesCount)
                )
                return Set(
                    (0..<Int(namesCount)).map { Mach.Port(named: names![$0], in: self.owningTask) }
                )
            }
        }

        /// Inserts a port into the port set.
        public func insert(_ port: Mach.Port) throws {
            try Mach.call(
                mach_port_insert_member(self.owningTask.name, port.name, self.name)
            )
        }
    }
}

extension Mach.Port {
    /// Moves the port into a port set.
    /// - Warning: If the port is already a member of any other port sets, it will be removed from them.
    public func move(to set: Mach.PortSet) throws {
        try Mach.call(
            mach_port_move_member(self.owningTask.name, self.name, set.name)
        )
    }

    /// Inserts the port into a port set.
    public func insert(into set: Mach.PortSet) throws { try set.insert(self) }
}
