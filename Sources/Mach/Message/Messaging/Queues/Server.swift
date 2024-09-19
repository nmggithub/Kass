import Darwin.Mach

extension Mach.Message {
    /// A message server for dequeuing messages.
    public class Server: Mach.Message.Queue {
        @available(*, unavailable, message: "Servers can only dequeue messages.")
        override public func enqueue(
            _ message: Mach.Message, options: Set<Mach.Messaging.Option> = [],
            timeout: mach_msg_timeout_t = MACH_MSG_TIMEOUT_NONE
        ) throws {}
        /// Set the sequence number of the queue.
        /// - Parameter sequenceNumber: The sequence number to set.
        /// - Throws: An error if the sequence number could not be set.
        public func setSequenceNumber(_ sequenceNumber: mach_port_seqno_t) throws {
            try Mach.call(
                mach_port_set_seqno(self.owningTask.name, self.name, sequenceNumber)
            )
        }
    }
}
