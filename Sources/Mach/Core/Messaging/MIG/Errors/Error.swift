import Darwin.Mach
import Foundation.NSError
import KassHelpers

extension Mach {
    /// An error code from a MIG server routine.
    public struct MIGErrorCode: KassHelpers.OptionEnum {
        /// The raw error code.
        public let rawValue: kern_return_t

        /// Represents a raw error code.
        public init(rawValue: kern_return_t) { self.rawValue = rawValue }

        public static let typeError = Self(rawValue: MIG_TYPE_ERROR)

        public static let replyMismatch = Self(rawValue: MIG_REPLY_MISMATCH)
        public static let remoteError = Self(rawValue: MIG_REMOTE_ERROR)
        public static let badId = Self(rawValue: MIG_BAD_ID)
        public static let badArguments = Self(rawValue: MIG_BAD_ARGUMENTS)
        public static let noReply = Self(rawValue: MIG_NO_REPLY)
        public static let exception = Self(rawValue: MIG_EXCEPTION)
        public static let arrayTooLarge = Self(rawValue: MIG_ARRAY_TOO_LARGE)
        public static let serverDied = Self(rawValue: MIG_SERVER_DIED)
        public static let trailerError = Self(rawValue: MIG_TRAILER_ERROR)
    }
    /// An error from a MIG server routine.
    public class MIGError: NSError, @unchecked Sendable {
        convenience init(_ error: MIGErrorCode) {
            self.init(
                domain: NSMachErrorDomain,
                code: Int(error.rawValue)
            )
        }
    }
}
