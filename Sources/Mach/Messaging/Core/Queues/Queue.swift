import Darwin.Mach

// MARK: - Message Queue
extension Mach {
    /// A message queue.
    /// - Important: This does not support a combined send and receive operation. For such an operation, use
    /// the ``Mach/Messaging/send(_:to:receiving:ofMaxSize:on:options:timeout:)`` function.
    public class MessageQueue: Mach.Port {
        /// Sends a message to the queue.
        public func enqueue(
            _ message: Mach.Message, options: Set<Mach.Messaging.Option> = [],
            timeout: mach_msg_timeout_t = MACH_MSG_TIMEOUT_NONE
        ) throws {
            try Mach.Messaging.send(message, to: self, options: options, timeout: timeout)
        }

        /// Receives a message from the queue.
        /// - Warning: This function blocks until a message is received.
        public func dequeue<ReceiveMessage: Mach.Message>(
            _ messageType: ReceiveMessage.Type = Mach.Message.self,
            options: Set<Mach.Messaging.Option> = [],
            timeout: mach_msg_timeout_t = MACH_MSG_TIMEOUT_NONE
        ) throws -> Mach.Message {
            try Mach.Messaging.receive(messageType, on: self, options: options, timeout: timeout)
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
            options: Set<Mach.Messaging.Option> = [],
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
            _ message: Mach.Message, options: Set<Mach.Messaging.Option> = [],
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
