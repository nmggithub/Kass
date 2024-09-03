import CCompat
import Darwin.Mach
import Foundation

/// Error codes from a Mach Interface Generator (MIG) server routine.
public enum MIGErrorCode: kern_return_t {
    case typeError = -300
    case replyMismatch = -301
    case remoteError = -302
    case badId = -303
    case badArguments = -304
    case noReply = -305
    case exception = -306
    case arrayTooLarge = -307
    case serverDied = -308
    case trailerError = -309
}

/// An error from a Mach Interface Generator (MIG) server routine.
public class MIGError: NSError, @unchecked Sendable {
    /// Create a new MIG error from an error code.
    /// - Parameter error: The error code.
    init(_ error: MIGErrorCode) {
        super.init(
            domain: NSMachErrorDomain,
            code: Int(error.rawValue)
        )
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
