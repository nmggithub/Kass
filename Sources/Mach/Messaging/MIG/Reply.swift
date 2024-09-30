public typealias MIGReply = Mach.Message.MIG.Reply

extension Mach.Message.MIG {
    public class Reply<MIGPayloadType: Payload>: Mach.Message, Mach.Message.WithTypedPayload {
        public typealias PayloadType = MIGPayloadType
    }
}
