import CCompat
import Foundation
import MachO

/// Error codes from a Mach Interface Generator (MIG) server routine.
/// - Remark: Most of the comments documenting the cases are taken from the XNU source code.
public enum MIGErrorCode: kern_return_t {
    /// client type check failure -- `MIG_TYPE_ERROR``
    case typeError = -300
    /// wrong reply message ID -- `MIG_REPLY_MISMATCH``
    case replyMismatch = -301
    /// server detected error -- `MIG_REMOTE_ERROR``
    case remoteError = -302
    /// bad request message ID -- `MIG_BAD_ID``
    case badId = -303
    /// server type check failure -- `MIG_BAD_ARGUMENTS``
    case badArguments = -304
    /// no reply should be send -- `MIG_NO_REPLY``
    case noReply = -305
    /// server raised exception -- `MIG_EXCEPTION``
    case exception = -306
    /// array not large enough -- `MIG_ARRAY_TOO_LARGE``
    case arrayTooLarge = -307
    /// server died -- `MIG_SERVER_DIED``
    case serverDied = -308
    /// trailer has an unknown format -- `MIG_TRAILER_ERROR``
    case trailerError = -309
}

/// An error from a Mach Interface Generator (MIG) server routine.
public class MIGError: NSError {
    /// Create a new MIG error from an error code.
    /// - Parameter error: The error code.
    init(_ error: MIGErrorCode) {
        super.init(
            domain: NSMachErrorDomain,
            code: Int(error.rawValue)
        )
    }
    // Swift complains if we don't implement this initializer
    required init?(coder: NSCoder) {
        return nil
    }
}
