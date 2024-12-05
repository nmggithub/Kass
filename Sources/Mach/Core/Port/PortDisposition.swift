import Darwin.Mach
import KassHelpers

extension Mach {
    /// Processing to perform on a port.
    public struct PortDisposition: KassHelpers.OptionEnum {

        public let rawValue: mach_msg_type_name_t
        public init(rawValue: mach_msg_type_name_t) { self.rawValue = rawValue }

        /// Move the receive right.
        public static let moveReceive = Self(
            rawValue: mach_msg_type_name_t(MACH_MSG_TYPE_MOVE_RECEIVE)
        )

        /// Move the send right.
        public static let moveSend = Self(
            rawValue: mach_msg_type_name_t(MACH_MSG_TYPE_MOVE_SEND)
        )

        /// Move the send-once right.
        public static let moveSendOnce = Self(
            rawValue: mach_msg_type_name_t(MACH_MSG_TYPE_MOVE_SEND_ONCE)
        )

        /// Copy the send right.
        public static let copySend = Self(
            rawValue: mach_msg_type_name_t(MACH_MSG_TYPE_COPY_SEND)
        )

        /// Make a send right.
        public static let makeSend = Self(
            rawValue: mach_msg_type_name_t(MACH_MSG_TYPE_MAKE_SEND)
        )

        /// Make a send-once right.
        public static let makeSendOnce = Self(
            rawValue: mach_msg_type_name_t(MACH_MSG_TYPE_MAKE_SEND_ONCE)
        )

        /// Copy the receive right.
        /// - Warning: A receive right can actually never be copied. This is just here for completeness.
        public static let copyReceive = Self(
            rawValue: mach_msg_type_name_t(MACH_MSG_TYPE_COPY_RECEIVE)
        )
    }
}

extension Mach.Port {
    /// Extracts a right from the port and brings it into the current task's name space.
    public func extractRight<PortType: Mach.Port>(
        using disposition: Mach.PortDisposition,
        as: PortType.Type = PortType.self
    ) throws -> PortType {
        var extractedRight = mach_port_name_t()
        // We have to pass this, but we ignore it. All it does it tell us what kind of right we got (which we should already know).
        var typeName = mach_msg_type_name_t()
        try Mach.call(
            mach_port_extract_right(
                self.owningTask.name, self.name, disposition.rawValue, &extractedRight, &typeName
            )
        )
        return PortType(named: extractedRight, inNameSpaceOf: self.owningTask)
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
