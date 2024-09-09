import Darwin.Mach

extension Mach.Message {
    /// A message server for dequeuing messages.
    public class Server: Mach.Message.Queue {
        @available(*, unavailable, message: "Servers can only dequeue messages.")
        override public func enqueue(
            _ message: Mach.Message, options: Set<Mach.Messaging.Option> = [],
            timeout: mach_msg_timeout_t = MACH_MSG_TIMEOUT_NONE
        ) throws {}
    }
}
