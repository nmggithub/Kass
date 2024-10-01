import Darwin.Mach
import Foundation.NSError

extension Mach {
    /// An error reply to a MIG request.
    /// - Important: This really just represents an empty reply with a return code, which might be `KERN_SUCCESS`. So
    /// the name "MIG error reply" is bit of a misnomer, but it's based on the name of the corresponding C struct.
    public final class MIGErrorReply: Mach.MIGReply<Mach.MIGErrorReply.ErrorPayload> {
        /// The error represented by the reply.
        public var error: Swift.Error {
            NSError(domain: NSMachErrorDomain, code: Int(self.payload!.returnCode))
        }
        public struct ErrorPayload: Mach.MIGPayload, Mach.TrivialMessagePayload {
            // based on `mig_reply_error_t`
            public var NDR: NDR_record_t
            public var returnCode: kern_return_t
        }
    }
}
