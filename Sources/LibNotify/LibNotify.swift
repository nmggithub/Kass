import KassHelpers
import MachCore
import notify

/// A Swift wrapper around the Libnotify C API.
public struct LibNotify: KassHelpers.Namespace {
    /// A helper for a notification name in Libnotify.
    public struct NotificationName {
        /// The name of the notification.
        public let name: String

        /// Initialize a notification name helper with a string.
        public init(_ name: String) {
            self.name = name
        }

        /// Posts a notification for the given name.
        public func post() throws {
            try LibNotify.call(notify_post(name))
        }

        /// Registers a notification handler for the given name, to be handled on the given dispatch queue.
        public func register(
            handler: @escaping notify_handler_t, onQueue queue: DispatchQueue
        ) throws -> NotificationToken {
            var token: Int32 = NOTIFY_TOKEN_INVALID
            try LibNotify.call(notify_register_dispatch(name, &token, queue, handler))
            return NotificationToken(rawValue: token)
        }

        /// Creates a notification token that can be used to check if any notification has been posted.
        public func register() throws -> NotificationToken {
            var token: Int32 = NOTIFY_TOKEN_INVALID
            try LibNotify.call(notify_register_check(name, &token))
            return NotificationToken(rawValue: token)
        }

        /// Requests that the given signal be sent to the process when a notification is posted.
        /// - Important: Once a signal is received ``NotificationToken/check()`` must be called for each
        ///     potential token to determine which name (if any) was responsible for the signal.
        public func register(signal: Int32) throws -> NotificationToken {
            var token: Int32 = NOTIFY_TOKEN_INVALID
            try LibNotify.call(notify_register_signal(name, signal, &token))
            return NotificationToken(rawValue: token)
        }

        /// Requests that a Mach message be sent to the given port when a notification is posted.
        /// - Important: The message ID field in the header of the message will be the value of the token
        ///     for the name that was responsible for the notification.
        public func register(machPort: inout Mach.Port?, flags: LibNotifyFlags) throws
            -> NotificationToken
        {
            var portName = machPort?.name ?? mach_port_name_t(MACH_PORT_NULL)
            var token: Int32 = NOTIFY_TOKEN_INVALID
            try LibNotify.call(notify_register_mach_port(name, &portName, flags.rawValue, &token))
            machPort = Mach.Port(named: portName)
            return NotificationToken(rawValue: token)
        }

        /// Requests that a the file behind a given file descriptor be written to when a notification is posted.
        /// - Important: The value of the token for the name responsible for the notification will be written to the
        ///     file descriptor.
        public func register(fileDescriptor fd: inout Int32, flags: LibNotifyFlags) throws
            -> NotificationToken
        {
            var token: Int32 = NOTIFY_TOKEN_INVALID
            try LibNotify.call(notify_register_file_descriptor(name, &fd, flags.rawValue, &token))
            return NotificationToken(rawValue: token)
        }
    }

    /// A notification token for Libnotify.
    public struct NotificationToken: RawRepresentable {
        /// The raw value of the notification token.
        public let rawValue: Int32

        /// Initialize a notification token with a raw value.
        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }

        /// Checks if a notification has been posted for this token.
        public func check() throws -> Bool {
            var result: Int32 = 0
            try LibNotify.call(notify_check(self.rawValue, &result))
            return result != 0
        }

        /// Cancels the notification token.
        public func cancel() throws {
            try LibNotify.call(notify_cancel(self.rawValue))
        }

        /// Resumes the notification token.
        public func resume() throws {
            try LibNotify.call(notify_resume(self.rawValue))
        }

        /// Sets an arbitrary state value for the notification token.
        public func setState(_ state: UInt64) throws {
            try LibNotify.call(notify_set_state(self.rawValue, state))
        }

        /// Gets the arbitrary state value for the notification token.
        public func getState() throws -> UInt64 {
            var state: UInt64 = 0
            try LibNotify.call(notify_get_state(self.rawValue, &state))
            return state
        }

        /// If the token is valid.
        var isValid: Bool {
            notify_is_valid_token(self.rawValue)
        }
    }
}
