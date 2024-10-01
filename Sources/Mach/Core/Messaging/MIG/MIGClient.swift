import Darwin.Mach
import Foundation

extension Mach {
    /// A client for a MIG subsystem.
    open class MIGClient: Mach.Port {
        /// The base routine ID for the remote MIG subsystem.
        public var baseRoutineId: mach_msg_id_t = 0

        /// Represents an existing MIG server port.
        public init(named name: mach_port_name_t, baseRoutineId: mach_msg_id_t) {
            self.baseRoutineId = baseRoutineId
            super.init(named: name)
        }

        @available(*, unavailable, message: "Use `init(named:baseRoutineId:)` instead.")
        public required init(named name: mach_port_name_t, inNameSpaceOf task: Mach.Task = .current)
        {
            self.baseRoutineId = 0
            super.init(named: name)
        }

        /// Performs a MIG routine.
        @discardableResult  // users can ignore the reply message if they want to
        public func doRoutine(
            _ routineIndex: mach_msg_id_t,
            request: MIGRequest<some Mach.MIGPayload>,
            on replyPort: Mach.Port? = nil
        ) throws -> MIGReply<Data> {
            try self.doRoutine(
                routineIndex,
                request: request,
                receiving: MIGReply<Data>.self
            )
        }

        /// Performs a MIG routine.
        @discardableResult  // users can ignore the reply message if they want to
        public func doRoutine<
            ReplyPayload: Mach.MIGPayload,
            Reply: MIGReply<ReplyPayload>
        >(
            _ routineIndex: mach_msg_id_t,
            request: MIGRequest<some Mach.MIGPayload>,
            receiving replyType: Reply.Type,
            on replyPort: Mach.Port = Mach.MIGReplyPort()
        ) throws -> Reply {
            let routineId = self.baseRoutineId + routineIndex
            request.header.msgh_id = routineId
            request.header.bits.remotePortDisposition = .copySend  // make a copy of the send right so we can reuse the port
            request.header.bits.localPortDisposition = .makeSendOnce  // make a send-once right so we can receive the reply
            let reply = try Mach.sendMessage(
                request, to: self,
                receiving: replyType, on: replyPort
            )
            guard reply.header.msgh_id != MACH_NOTIFY_SEND_ONCE else {
                throw Mach.MIGError(.serverDied)
            }  // the server deallocated the send-once right without using it, assume it died
            guard reply.header.msgh_id == routineId + 100 else {
                throw Mach.MIGError(.replyMismatch)
            }  // the reply ID should be the request ID + 100
            guard reply.header.remotePort == Mach.Port.Nil else { throw Mach.MIGError(.typeError) }  // the reply should clear the remote port
            // If the reply is not complex and the same size as a MIG error reply, assume it is an error reply.
            if !reply.header.bits.isMessageComplex
                && reply.header.msgh_size == MemoryLayout<mig_reply_error_t>.size
            {
                let errorReply = Mach.MIGErrorReply(headerPointer: reply.serialize())
                /// An empty successful reply will have the same size as a MIG error reply, but the return code will be `KERN_SUCCESS`.
                guard errorReply.payload!.returnCode == KERN_SUCCESS else {
                    throw errorReply.error
                }
            }
            return reply
        }
    }
}
