import Darwin.Mach

// MARK: - Message Queue
extension Mach {
    /// A message queue.
    /// - Important: This does not support a combined send and receive operation. For such an operation, use
    /// the ``Mach/sendMessage(_:to:receiving:ofMaxSize:on:options:timeout:)`` function.
    public class MessageQueue: Mach.Port {
        /// Sends a message to the queue.
        public func enqueue(
            _ message: Mach.Message, options: Mach.MessageOptions = [],
            timeout: mach_msg_timeout_t = MACH_MSG_TIMEOUT_NONE
        ) throws {
            try Mach.sendMessage(message, to: self, options: options, timeout: timeout)
        }

        /// Receives a message from the queue.
        /// - Warning: This function blocks until a message is received.
        public func dequeue<ReceiveMessage: Mach.Message>(
            _ messageType: ReceiveMessage.Type = Mach.Message.self,
            options: Mach.MessageOptions = [],
            timeout: mach_msg_timeout_t = MACH_MSG_TIMEOUT_NONE
        ) throws -> Mach.Message {
            try Mach.receiveMessage(messageType, on: self, options: options, timeout: timeout)
        }
    }
}

// MARK: - Message Client
extension Mach {
    /// A message client for enqueuing messages.
    public class MessageClient: Mach.MessageQueue {
        @available(*, unavailable, message: "Clients can only enqueue messages.")
        override public func dequeue<ReceiveMessage>(
            _ messageType: ReceiveMessage.Type = Mach.Message.self,
            options: Mach.MessageOptions = [],
            timeout: mach_msg_timeout_t = MACH_MSG_TIMEOUT_NONE
        ) throws -> Mach.Message where ReceiveMessage: Mach.Message {
            Mach.Message()
        }
    }
}

// MARK: - Message Server
extension Mach {
    /// A message server for dequeuing messages.
    public class MessageServer: Mach.MessageQueue {
        @available(*, unavailable, message: "Servers can only dequeue messages.")
        override public func enqueue(
            _ message: Mach.Message, options: Mach.MessageOptions = [],
            timeout: mach_msg_timeout_t = MACH_MSG_TIMEOUT_NONE
        ) throws {}

        /// Sets the sequence number of the queue.
        public func setSequenceNumber(_ sequenceNumber: mach_port_seqno_t) throws {
            try Mach.call(
                mach_port_set_seqno(self.owningTask.name, self.name, sequenceNumber)
            )
        }
    }
}

// MARK: - Message Peeking

// These were "functional" C macros in the original code, but Swift doesn't support those.
private func MACH_RCV_TRAILER_ELEMENTS(_ x: Int32) -> Int32 { ((x) & 0xf) << 24 }
private func MACH_RCV_TRAILER_TYPE(_ x: Int32) -> Int32 { ((x) & 0xf) << 28 }

extension Mach {
    /// A peeked preview of a message.
    public struct PeekedMessage {
        /// The advertised size of the message.
        public var size: mach_msg_size_t

        /// The message ID.
        public var id: mach_msg_id_t

        /// The trailer.
        public var trailer: mach_msg_audit_trailer_t
    }
}

extension Mach.MessageServer {
    /// Peeks at the message in the queue with the given sequence number.
    public func peek(sequenceNumber: inout mach_port_seqno_t) throws -> Mach.PeekedMessage {
        var messageSize = mach_msg_size_t(0)
        var messageID = mach_msg_id_t(0)
        let trailer = try Mach.callWithCountInOut(type: mach_msg_audit_trailer_t.self) {
            trailerInfo, count in
            mach_port_peek(
                self.owningTask.name,
                self.name,
                // We peek as much of the trailer as the kernel will let us (which is everything up to, and including, to the audit token).
                mach_msg_trailer_type_t(
                    MACH_RCV_TRAILER_TYPE(MACH_MSG_TRAILER_FORMAT_0)  // This results in 0, so it's not strictly necessary, but this is the documented way to do it.
                        | MACH_RCV_TRAILER_ELEMENTS(MACH_RCV_TRAILER_AUDIT)
                ),
                &sequenceNumber,
                &messageSize,
                &messageID,
                trailerInfo,
                &count
            )
        }
        return Mach.PeekedMessage(
            size: messageSize,
            id: messageID,
            trailer: trailer
        )
    }
}
