import Darwin.Mach
import Foundation
import MachBase
import MachMsg

public typealias MIGErrorReply = Mach.Message.MIG.ErrorReply
extension Mach.Message.MIG {
    /// An error reply to a MIG message.
    /// - Important: This really just represents an empty reply with a return code, which might be `KERN_SUCCESS`. So
    /// the name "MIG error reply" is bit of a misnomer, but it's based on the name of the corresponding C struct.
    public final class ErrorReply: Reply<ErrorReply.ErrorPayload> {
        /// The error represented by the reply.
        public var error: Swift.Error {
            NSError(domain: NSMachErrorDomain, code: Int(self.payload!.returnCode))
        }
        public struct ErrorPayload: MIG.Payload, Mach.Message.Payload.Trivial {
            // based on `mig_reply_error_t`
            public var NDR: NDR_record_t
            public var returnCode: kern_return_t
        }
    }
}
