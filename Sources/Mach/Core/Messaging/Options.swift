import Darwin.Mach
import KassHelpers

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

extension Mach {
    /// A type of trailer to receive with a message.
    public struct TrailerType: KassHelpers.NamedOptionEnum {
        /// The name of the type, if it can be determined.
        public var name: String?

        /// Represents a trailer type with an optional name.
        public init(name: String?, rawValue: UInt32) {
            self.name = name
            self.rawValue = rawValue
        }

        /// The unshifted raw value of the trailer type.
        private var unshiftedRawValue: UInt32 = 0

        /// The raw value of the trailer type.
        public var rawValue: mach_msg_trailer_type_t {
            get { mach_msg_trailer_type_t((unshiftedRawValue & 0xf) << 28) }
            set { unshiftedRawValue = UInt32(newValue) }
        }

        /// All known trailer types.
        public static let allCases: [Self] = [.format0]

        public static let format0 =
            Self(rawValue: mach_msg_trailer_type_t(MACH_MSG_TRAILER_FORMAT_0))
    }
}
extension Mach.MessageOptions {
    public static func receiveTrailerType(_ type: Mach.TrailerType) -> Self {
        Self(rawValue: mach_msg_option_t(type.rawValue))
    }
}

extension Mach {
    /// A set of trailer elements to receive with a message.
    public struct TrailerElements: OptionSet, KassHelpers.NamedOptionEnum {
        /// The name of the elements, if it can be determined.
        public var name: String?

        /// Represents a trailer elements with an optional name.
        public init(name: String?, rawValue: UInt32) {
            self.name = name
            self.rawValue = rawValue
        }

        /// The unshifted raw value of the trailer elements.
        private var unshiftedRawValue: UInt32 = 0

        /// The raw value of the trailer elements.
        /// - Note: This is defined as a `mach_msg_trailer_type_t` for better compatibility with `mach_port_peek` API.
        public var rawValue: mach_msg_trailer_type_t {
            get { mach_msg_trailer_type_t((unshiftedRawValue & 0xf) << 24) }
            set { unshiftedRawValue = UInt32(newValue) }
        }

        /// All known trailer elements.
        public static let allCases: [Self] = [
            .null, .sequenceNumber, .sender, .audit, .context, .mac, .labels,
        ]

        public static let null = Self(
            name: "null",
            rawValue: mach_msg_trailer_type_t(MACH_RCV_TRAILER_NULL)
        )

        public static let sequenceNumber = Self(
            name: "sequenceNumber",
            rawValue: mach_msg_trailer_type_t(MACH_RCV_TRAILER_SEQNO)
        )

        public static let sender = Self(
            name: "sender",
            rawValue: mach_msg_trailer_type_t(MACH_RCV_TRAILER_SENDER)
        )

        public static let audit = Self(
            name: "audit",
            rawValue: mach_msg_trailer_type_t(MACH_RCV_TRAILER_AUDIT)
        )

        public static let context = Self(
            name: "context",
            rawValue: mach_msg_trailer_type_t(MACH_RCV_TRAILER_CTX)
        )

        public static let mac = Self(
            name: "mac",
            // Despite the difference in naming, this *is* the correct constant.
            rawValue: mach_msg_trailer_type_t(MACH_RCV_TRAILER_AV)
        )

        public static let labels: Self = Self(
            name: "labels",
            rawValue: mach_msg_trailer_type_t(MACH_RCV_TRAILER_LABELS)
        )
    }
}

extension Mach.MessageOptions {
    public static func receiveTrailerElements(_ elements: Mach.TrailerElements) -> Self {
        Self(rawValue: mach_msg_option_t(elements.rawValue))
    }
}

extension Mach.TrailerType {
    init(_ type: Self, withElements elements: Mach.TrailerElements) {
        self.init(
            name: type.name,
            rawValue: type.rawValue | elements.rawValue
        )
    }
}
