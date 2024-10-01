import Darwin.Mach

extension Mach.Message {
    /// A message queue.
    /// - Important: This does not support a combined send and receive operation. For such an operation, use
    /// the ``Mach/Messaging/send(_:to:receiving:ofMaxSize:on:options:timeout:)`` function.
    public class Queue: Mach.Port {
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
