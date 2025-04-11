import Darwin.Mach
import KassHelpers

extension Mach {
    /// Processing to perform on a port.
    public struct PortDisposition: KassHelpers.NamedOptionEnum {
        /// The name of the disposition, if it can be determined.
        public var name: String?

        /// Represents a port disposition with an optional name.
        public init(name: String?, rawValue: UInt32) {
            self.name = name
            self.rawValue = rawValue
        }

        /// The raw value of the disposition.
        public let rawValue: UInt32

        // All known port dispositions.
        public static let allCases: [Self] = [
            .moveReceive, .moveSend, .moveSendOnce,
            .copySend, .makeSend, .makeSendOnce,
            .copyReceive,
        ]

        /// Move the receive right.
        public static let moveReceive = Self(
            name: "moveReceive", rawValue: mach_msg_type_name_t(MACH_MSG_TYPE_MOVE_RECEIVE)
        )

        /// Move the send right.
        public static let moveSend = Self(
            name: "moveSend", rawValue: mach_msg_type_name_t(MACH_MSG_TYPE_MOVE_SEND)
        )

        /// Move the send-once right.
        public static let moveSendOnce = Self(
            name: "moveSendOnce", rawValue: mach_msg_type_name_t(MACH_MSG_TYPE_MOVE_SEND_ONCE)
        )

        /// Copy the send right.
        public static let copySend = Self(
            name: "copySend", rawValue: mach_msg_type_name_t(MACH_MSG_TYPE_COPY_SEND)
        )

        /// Make a send right.
        public static let makeSend = Self(
            name: "makeSend", rawValue: mach_msg_type_name_t(MACH_MSG_TYPE_MAKE_SEND)
        )

        /// Make a send-once right.
        public static let makeSendOnce = Self(
            name: "makeSendOnce", rawValue: mach_msg_type_name_t(MACH_MSG_TYPE_MAKE_SEND_ONCE)
        )

        /// Copy the receive right.
        /// - Warning: A receive right can actually never be copied. This is just here for completeness.
        public static let copyReceive = Self(
            name: "copyReceive", rawValue: mach_msg_type_name_t(MACH_MSG_TYPE_COPY_RECEIVE)
        )
    }
}

extension Mach.Port {
    /// Extracts a right from the port and brings it into the a given task's name space.
    public func extractRight<PortType: Mach.Port>(
        using disposition: Mach.PortDisposition,
        intoNameSpaceOf receivingTask: Mach.Task = .current
    ) throws -> PortType {
        var extractedRight = mach_port_name_t()
        // We have to pass this, but we ignore it. All it does it tell us what kind of right we got (which we should already know).
        var typeName = mach_msg_type_name_t()
        try Mach.call(
            mach_port_extract_right(
                self.owningTask.name, self.name, disposition.rawValue, &extractedRight, &typeName
            )
        )
        return PortType(named: extractedRight, inNameSpaceOf: receivingTask)
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
