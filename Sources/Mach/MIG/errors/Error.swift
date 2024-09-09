import Darwin.Mach
import Foundation

extension Mach.Message.MIG {
    public class Error: NSError {
        /// Error code from a Mach Interface Generator (MIG) server routine.
        public enum Code: kern_return_t {
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
        convenience init(_ error: Code) {
            self.init(
                domain: NSMachErrorDomain,
                code: Int(error.rawValue)
            )
        }
    }
}
