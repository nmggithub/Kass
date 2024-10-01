extension Mach {
    public class MIGRequest<MIGPayloadType: Mach.MIGPayload>: Mach.Message,
        Mach.MessageWithTypedPayload
    {
        public typealias PayloadType = MIGPayloadType
    }
}
