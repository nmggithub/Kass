extension Mach {
    /// A MIG request message.
    public class MIGRequest<MIGPayloadType: Mach.MIGPayload>: Mach.Message,
        Mach.MessageWithTypedPayload
    {
        public typealias PayloadType = MIGPayloadType
    }
}
