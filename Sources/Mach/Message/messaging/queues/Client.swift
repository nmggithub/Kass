import Darwin.Mach
import MachBase

extension Mach.Message {
    /// A message client for enqueuing messages.
    public class Client: Mach.Message.Queue {
        @available(*, unavailable, message: "Clients can only enqueue messages.")
        override public func dequeue<ReceiveMessage>(
            _ messageType: ReceiveMessage.Type = Mach.Message.self,
            options: Set<Mach.MachMsg.Option> = [],
            timeout: mach_msg_timeout_t = MACH_MSG_TIMEOUT_NONE
        ) throws -> Mach.Message where ReceiveMessage: Mach.Message {
            Mach.Message()
        }
    }
}
