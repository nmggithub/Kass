import KassHelpers
import notify

extension LibNotify {
    /// Flags for Libnotify.
    public struct LibNotifyFlags: OptionSet, KassHelpers.NamedOptionEnum {
        /// The name of the flag, if it can be determined.
        public var name: String?

        /// Represents a Libnotify flag with an optional name.
        public init(name: String?, rawValue: Int32) {
            self.name = name
            self.rawValue = rawValue
        }

        /// The raw value of the flag.
        public let rawValue: Int32

        /// The individual flags in the collection.
        public var flags: [Self] { Self.allCases.filter { self.contains($0) } }

        /// All of the Libnotify flags.
        public static let allCases: [Self] = [.reuse]

        /// Reuse the given notification mechanism if possible.
        public static let reuse = Self(name: "reuse", rawValue: NOTIFY_REUSE)
    }

}
