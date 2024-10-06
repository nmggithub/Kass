import KassC.AttrPrivate
import KassHelpers

extension BSD {

    // MARK: - FS Options
    /// Options for file system operations.
    public struct FSOptions: OptionSet, Sendable, CaseIterable, KassHelpers.NamedOptionEnum {
        /// The name of the options, if it can be determined.
        public let name: String?

        /// Represents options with an optional name.
        public init(name: String?, rawValue: UInt32) {
            self.name = name
            self.rawValue = rawValue
        }

        /// The raw value of the options.
        public let rawValue: UInt32

        /// The individual options in the set.
        public var options: [Self] { Self.allCases.filter { contains($0) } }

        /// All known options.
        public static let allCases: [Self] = [
            .noFollow,
            .noFollowWithError,
            .noInMemoryUpdate,
            .reportFullSize,
            .returnInvalidAttributes,
            .exchangeDataOnly,
            .useExtendedCommonAttributes,
            .listSnapshot,
            .noFirmlinkPath,
            .followFirmlink,
            .returnRealDevice,
            .utimesNull,
        ]

        /// Do not follow symbolic links.
        public static let noFollow = Self(name: "noFollow", rawValue: UInt32(FSOPT_NOFOLLOW))

        /// - Note: This option is the same as ``noFollow``, but with the addition that
        /// an error is returned if a symbolic link is encountered.
        public static let noFollowWithError = Self(
            name: "noFollowWithError", rawValue: UInt32(FSOPT_NOFOLLOW_ANY)
        )

        public static let noInMemoryUpdate = Self(
            name: "noInMemoryUpdate", rawValue: UInt32(FSOPT_NOINMEMUPDATE)
        )

        public static let reportFullSize = Self(
            name: "reportFullSize", rawValue: UInt32(FSOPT_REPORT_FULLSIZE)
        )

        public static let returnInvalidAttributes = Self(
            name: "returnInvalidAttributes", rawValue: UInt32(FSOPT_PACK_INVAL_ATTRS)
        )

        public static let useExtendedCommonAttributes = Self(
            name: "useExtendedCommonAttributes", rawValue: UInt32(FSOPT_ATTR_CMN_EXTENDED)
        )

        // Private Options

        public static let exchangeDataOnly = Self(
            name: "exchangeDataOnly", rawValue: UInt32(FSOPT_EXCHANGE_DATA_ONLY)
        )

        public static let listSnapshot = Self(
            name: "listSnapshot", rawValue: UInt32(FSOPT_LIST_SNAPSHOT)
        )

        public static let noFirmlinkPath = Self(
            name: "noFirmlinkPath", rawValue: UInt32(FSOPT_NOFIRMLINKPATH)
        )

        public static let followFirmlink = Self(
            name: "followFirmlink", rawValue: UInt32(FSOPT_FOLLOW_FIRMLINK)
        )

        public static let returnRealDevice = Self(
            name: "returnRealDevice", rawValue: UInt32(FSOPT_RETURN_REALDEV)
        )

        public static let utimesNull = Self(
            name: "utimesNull", rawValue: UInt32(FSOPT_UTIMES_NULL)
        )
    }
}
