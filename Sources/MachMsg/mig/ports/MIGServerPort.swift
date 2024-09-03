import CCompat
import Darwin.Mach
import Foundation
import MachPort

/// A port to a MIG server.
open class MIGServerPort: MachPort {
    /// The base routine ID for the MIG server.
    public var baseRoutineId: mach_msg_id_t

    /// Represent an existing raw MIG server port.
    /// - Parameters:
    ///   - rawPort: The raw port.
    ///   - baseRoutineId: The base routine ID for the MIG server.
    public init(rawPort: mach_port_t, baseRoutineId: mach_msg_id_t) {
        self.baseRoutineId = baseRoutineId
        super.init(rawValue: rawPort)
    }

    /// Perform a MIG routine.
    /// - Parameters:
    ///   - routineIndex: The index of the routine.
    ///   - request: The request to send.
    ///   - replyPort: The port on which to receive the reply.
    /// - Returns: The reply to the request.
    @discardableResult  // users can ignore the reply message if they want to
    public func doRoutine(
        _ routineIndex: mach_msg_id_t,
        request: MIGRequest<some MIGPayload>,
        on replyPort: MachMessagePort? = nil
    ) throws -> MIGReply<Data> {
        try self.doRoutine(
            routineIndex,
            request: request,
            receiving: MIGReply<Data>.self
        )
    }

    /// Perform a MIG routine.
    /// - Parameters:
    ///   - routineIndex: The index of the routine.
    ///   - request: The request to send.
    ///   - receiving: The type of the reply to receive.
    ///   - replyPort: The port on which to receive the reply.
    /// - Returns: The reply to the request.
    @discardableResult  // users can ignore the reply message if they want to
    public func doRoutine<
        ReplyPayload: MIGPayload,
        Reply: MIGReply<ReplyPayload>
    >(
        _ routineIndex: mach_msg_id_t,
        request: MIGRequest<some MIGPayload>,
        receiving replyType: Reply.Type,
        on replyPort: MachMessagePort = MIGReplyPort()
    ) throws -> Reply {
        let routineId = self.baseRoutineId + routineIndex
        request.header.messageID = routineId
        let reply = try MachMessaging.send(
            request, to: self.withDisposition(.copySend),
            receiving: replyType, on: replyPort
        )
        guard reply.header.messageID != MACH_NOTIFY_SEND_ONCE else { throw MIGError(.serverDied) }  // the server deallocated the send-once right without using it, assume it died
        guard reply.header.messageID == routineId + 100 else { throw MIGError(.replyMismatch) }  // the reply ID should be the request ID + 100
        guard reply.header.remotePort == nil else { throw MIGError(.typeError) }  // the reply should clear the remote port
        // If the reply is not complex and the same size as a MIG error reply, assume it is an error reply.
        if !reply.header.bits.isMessageComplex
            && reply.header.messageSize == MemoryLayout<mig_reply_error_t>.size
        {
            let errorReply = reply.as(MIGErrorReply.self)
            /// An empty successful reply will have the same size as a MIG error reply, but the return code will be `KERN_SUCCESS`.
            guard errorReply.payload!.returnCode == KERN_SUCCESS else {
                throw errorReply.error
            }
        }
        return reply
    }

    public required init(nilLiteral: ()) {
        self.baseRoutineId = 0
        super.init(nilLiteral: ())
    }

    public required init(rawValue: mach_port_t) {
        self.baseRoutineId = 0
        super.init(rawValue: rawValue)
    }
}
