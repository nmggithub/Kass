import CCompat
import Darwin.Mach
import Foundation

/// An error reply to a MIG message.
/// - Important: This really just represents an empty reply with a return code, which might be `KERN_SUCCESS`. So
/// the name "MIG error reply" is bit of a misnomer, but it's based on the name of the corresponding C struct.
public final class MIGErrorReply: MIGReply<MIGErrorReply.Payload> {
    /// The error represented by the reply.
    public var error: Swift.Error {
        NSError(domain: NSMachErrorDomain, code: Int(self.payload!.returnCode))
    }
    /// The payload of a MIG error reply.
    public struct Payload: FixedLengthTrivialPayload, MIGPayloadWithNDR {
        // based on `mig_reply_error_t`
        public let NDR: NDR_record_t
        public let returnCode: Int32
    }
    public required init(rawValue: UnsafeMutablePointer<mach_msg_header_t>) {
        super.init(rawValue: rawValue)
    }
}
