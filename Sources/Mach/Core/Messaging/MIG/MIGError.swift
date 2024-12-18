import Darwin.Mach
import Foundation.NSError
import KassHelpers

extension Mach {
    /// An error code from a MIG server routine.
    public struct MIGErrorCode: KassHelpers.NamedOptionEnum {
        /// The name of the error code, if it can be determined.
        public var name: String?

        /// Represents a MIG error code with an optional name.
        public init(name: String?, rawValue: kern_return_t) {
            self.name = name
            self.rawValue = rawValue
        }

        /// The raw value of the error code.
        public let rawValue: kern_return_t

        /// All known MIG error codes.
        public static let allCases: [Self] = [
            .typeError, .replyMismatch, .remoteError, .badID, .badArguments, .noReply, .exception,
            .arrayTooLarge, .serverDied, .trailerError,
        ]

        /// There was a type-checking failure.
        public static let typeError = Self(name: "typeError", rawValue: MIG_TYPE_ERROR)

        /// The reply had the wrong message ID.
        public static let replyMismatch = Self(name: "replyMismatch", rawValue: MIG_REPLY_MISMATCH)

        /// The server detected an error.
        public static let remoteError = Self(name: "remoteError", rawValue: MIG_REMOTE_ERROR)

        /// The request had a bad message ID.
        public static let badID = Self(name: "badID", rawValue: MIG_BAD_ID)

        /// The request had bad arguments.
        public static let badArguments = Self(name: "badArguments", rawValue: MIG_BAD_ARGUMENTS)

        /// The server opted to not send a defined reply.
        public static let noReply = Self(name: "noReply", rawValue: MIG_NO_REPLY)

        /// The server raised an exception.
        public static let exception = Self(name: "exception", rawValue: MIG_EXCEPTION)

        /// A passed-in array was too large.
        public static let arrayTooLarge = Self(name: "arrayTooLarge", rawValue: MIG_ARRAY_TOO_LARGE)

        /// The server died.
        public static let serverDied = Self(name: "serverDied", rawValue: MIG_SERVER_DIED)

        /// The trailer for the reply was invalid.
        public static let trailerError = Self(name: "trailerError", rawValue: MIG_TRAILER_ERROR)
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
