import Darwin.Mach

extension Mach {
    /// Processing to perform on a port.
    public enum PortDisposition: mach_msg_type_name_t {
        /// No processing.
        case none = 0

        /// Move the receive right.
        case moveReceive = 16

        /// Move the send right.
        case moveSend = 17

        /// Move the send-once right.
        case moveSendOnce = 18

        /// Copy the send right.
        case copySend = 19

        /// Make a send right.
        case makeSend = 20

        /// Make a send-once right.
        case makeSendOnce = 21

        /// Copy the receive right.
        /// - Warning: A receive right can actually never be copied. This is just here for completeness.
        case copyReceive = 22
    }
}

extension Mach.Port {
    /// Extracts a right from the port and brings it into the current task's name space.
    public func extractRight(using disposition: Mach.PortDisposition) throws -> Mach.Port {
        var extractedRight = mach_port_name_t()
        // We have to pass this, but we ignore it. All it does it tell us what kind of right we got (which we should already know).
        var typeName = mach_msg_type_name_t()
        try Mach.call(
            mach_port_extract_right(
                self.owningTask.name, self.name, disposition.rawValue, &extractedRight, &typeName
            )
        )
        return Mach.Port(named: extractedRight, inNameSpaceOf: self.owningTask)
    }

    /// Inserts a right from the port into the specified task's name space.
    public func insertRight(
        intoNameSpaceOf task: Mach.Task, using disposition: Mach.PortDisposition
    ) throws {
        try Mach.call(
            mach_port_insert_right(task.name, self.name, self.name, disposition.rawValue)
        )
    }
}
