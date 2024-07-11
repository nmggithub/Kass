import CCompat
import Darwin
import Foundation

/// An error reply to a Mach Interface Generator (MIG) message.
public class MIGErrorReply: MIGReply<MIGErrorReply.Payload> {
    /// The error represented by the reply.
    public var error: Swift.Error {
        NSError(domain: NSMachErrorDomain, code: Int(self.payload!.returnCode))
    }
    /// The payload of a MIG error reply.
    public struct Payload {  // based on `mig_reply_error_t`
        fileprivate let NDR: NDR_record_t
        public let returnCode: Int32
    }
    /// Create a new MIG error message.
    public required init() {
        super.init(
            descriptorTypes: [],
            payloadType: Payload.self
        )
    }
}
