import Darwin

/// A Mach Interface Generator (MIG) reply message.
open class MIGReply<Payload>: MachMessage<Payload> {
    /// Create a new MIG reply with the given payload and descriptor types.
    /// - Parameters:
    ///   - descriptorTypes: The types of the descriptors for the MIG reply.
    ///   - payloadType: The type of the payload for the MIG reply.
    ///   - payloadSize: The size of the payload for the MIG reply (ignored if `payloadType is specified`).
    /// - Important: If you will be using an untyped payload, you must specify the size of the payload in bytes in lieu of a payload type.
    /// - Important: The size of the payload must be at least the size of a `MIGErrorReply.Payload`.
    public override init(
        descriptorTypes: [any MachMessageDescriptor.Type]? = nil,
        payloadType: Payload.Type = Never.self,
        payloadSize: Int? = nil
    ) {
        super.init(
            descriptorTypes: descriptorTypes,
            payloadType: Payload.self,
            payloadSize: payloadSize
        )
    }

}

/// A Mach Interface Generator (MIG) reply message with an untyped payload.
public class UntypedMIGReply: MIGReply<Never> {
    /// Create a new untyped MIG reply with the given payload size.
    /// - Parameters:
    ///   - payloadSize: The size of the payload in bytes.
    ///   - descriptorTypes: The types of the descriptors for the MIG reply, if any.
    public init(
        payloadSize: mach_msg_size_t = 0,
        descriptorTypes: [any MachMessageDescriptor.Type]? = nil
    ) {
        super.init(
            descriptorTypes: descriptorTypes,
            payloadSize: Int(payloadSize)
        )
    }
}
