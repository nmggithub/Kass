import Darwin.Mach
import Foundation
import MachBase
import MachMsg
import MachPort

extension Mach.Message.MIG {
    open class Client: Mach.Port {
        /// The base routine ID for the remote MIG server.
        public var baseRoutineId: mach_msg_id_t = 0
        /// Represent an existing raw MIG server port.
        /// - Parameters:
        ///   - name: The name of the port.
        ///   - baseRoutineId: The base routine ID for the remote MIG server.
        public init(named name: mach_port_name_t, baseRoutineId: mach_msg_id_t) {
            self.baseRoutineId = baseRoutineId
            super.init(named: name)
        }

        @available(*, unavailable, message: "Use `init(named:baseRoutineId:)` instead.")
        public required init(named name: mach_port_name_t) {
            self.baseRoutineId = 0
            super.init(named: name)
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
            request: MIGRequest<some Payload>,
            on replyPort: Mach.Port? = nil
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
            ReplyPayload: Payload,
            Reply: MIGReply<ReplyPayload>
        >(
            _ routineIndex: mach_msg_id_t,
            request: MIGRequest<some Payload>,
            receiving replyType: Reply.Type,
            on replyPort: Mach.Port = ReplyPort()
        ) throws -> Reply {
            let routineId = self.baseRoutineId + routineIndex
            request.header.messageID = routineId
            request.header.bits.remotePortDisposition = .copySend  // make a copy of the send right so we can reuse the port
            let reply = try Mach.Messaging.send(
                request, to: self,
                receiving: replyType, on: replyPort
            )
            guard reply.header.messageID != MACH_NOTIFY_SEND_ONCE else {
                throw Error(.serverDied)
            }  // the server deallocated the send-once right without using it, assume it died
            guard reply.header.messageID == routineId + 100 else { throw Error(.replyMismatch) }  // the reply ID should be the request ID + 100
            guard reply.header.remotePort == Mach.Port.Nil else { throw Error(.typeError) }  // the reply should clear the remote port
            // If the reply is not complex and the same size as a MIG error reply, assume it is an error reply.
            if !reply.header.bits.isMessageComplex
                && reply.header.messageSize == MemoryLayout<mig_reply_error_t>.size
            {
                let errorReply = ErrorReply(rawValue: reply.rawValue)
                /// An empty successful reply will have the same size as a MIG error reply, but the return code will be `KERN_SUCCESS`.
                guard errorReply.payload!.returnCode == KERN_SUCCESS else {
                    throw errorReply.error
                }
            }
            return reply
        }
    }
}
