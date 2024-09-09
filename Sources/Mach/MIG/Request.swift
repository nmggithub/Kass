public typealias MIGRequest = Mach.Message.MIG.Request

extension Mach.Message.MIG {
    public class Request<MIGPayloadType: Payload>: Mach.Message, Mach.Message.WithTypedPayload {
        public typealias PayloadType = MIGPayloadType
    }
}
