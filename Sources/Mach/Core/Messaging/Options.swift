import Darwin.Mach

extension Mach {
    /// Options for sending and receiving messages.
    public struct MessageOptions: OptionSet, Sendable {
        /// The raw option value.
        public let rawValue: mach_msg_option_t

        /// Represents an option with a raw value.
        public init(rawValue: mach_msg_option_t) { self.rawValue = rawValue }

        public static let send = Self(rawValue: MACH_SEND_MSG)
        public static let receive = Self(rawValue: MACH_RCV_MSG)
        public static let receiveLarge = Self(rawValue: MACH_RCV_LARGE)
        public static let receiveLargeIdentity = Self(rawValue: MACH_RCV_LARGE_IDENTITY)
        public static let sendTimeout = Self(rawValue: MACH_SEND_TIMEOUT)
        public static let sendOverride = Self(rawValue: MACH_SEND_OVERRIDE)
        public static let sendInterrupt = Self(rawValue: MACH_SEND_INTERRUPT)
        public static let sendNotify = Self(rawValue: MACH_SEND_NOTIFY)
        public static let sendFilterNonfatal = Self(rawValue: MACH_SEND_FILTER_NONFATAL)
        public static let sendTrailer = Self(rawValue: MACH_SEND_TRAILER)
        public static let sendNoImportance = Self(rawValue: MACH_SEND_NOIMPORTANCE)
        public static let sendSyncOverride = Self(rawValue: MACH_SEND_SYNC_OVERRIDE)
        public static let sendPropagateQOS = Self(rawValue: MACH_SEND_PROPAGATE_QOS)
        public static let sendSyncBootstrapCheckin = Self(
            rawValue: MACH_SEND_SYNC_BOOTSTRAP_CHECKIN
        )
        public static let receiveTimeout = Self(rawValue: MACH_RCV_TIMEOUT)
        public static let receiveInterrupt = Self(rawValue: MACH_RCV_INTERRUPT)
        public static let receiveVoucher = Self(rawValue: MACH_RCV_VOUCHER)
        public static let receiveGuardedDesc = Self(rawValue: MACH_RCV_GUARDED_DESC)
        public static let receiveSyncWait = Self(rawValue: MACH_RCV_SYNC_WAIT)
        public static let receiveSyncPeek = Self(rawValue: MACH_RCV_SYNC_PEEK)
        public static let strictReply = Self(rawValue: MACH_MSG_STRICT_REPLY)
    }
}
