extension Mach {
    /// A MIG reply message.
    public class MIGReply<MIGPayloadType: Mach.MIGPayload>: Mach.Message,
        Mach.MessageWithTypedPayload
    {
        public typealias PayloadType = MIGPayloadType
    }
}
