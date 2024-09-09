extension Mach.Message {
    /// A message payload.
    public protocol Payload {
        /// Load a payload from a raw buffer.
        /// - Parameter buffer: The raw buffer.
        /// - Returns: The payload, or `nil` if the buffer does not contain a valid payload of this type.
        static func fromRawPayloadBuffer(_ buffer: UnsafeRawBufferPointer) -> Self?
        /// Convert the payload to a raw buffer.
        /// - Returns: The raw buffer.
        func toRawPayloadBuffer() -> UnsafeRawBufferPointer
    }
    /// A message with a typed payload.
    public protocol WithTypedPayload: Mach.Message {
        associatedtype PayloadType: Mach.Message.Payload
        /// The typed message payload.
        var payload: PayloadType? { get set }
    }
}

extension Mach.Message.WithTypedPayload {
    /// The typed message payload.
    public var payload: PayloadType? {
        get {
            guard let payloadBuffer = payloadBuffer else { return nil }
            return PayloadType.fromRawPayloadBuffer(payloadBuffer)
        }
        set {
            payloadBuffer = newValue?.toRawPayloadBuffer()
        }
    }
    /// Create a message with a set of descriptors and a payload.
    /// - Parameters:
    ///   - descriptors: The descriptors to include in the message.
    ///   - payload: The payload to include in the message.
    public init(
        descriptors: [any Mach.Message.Body.Descriptor]? = nil,
        payload: PayloadType
    ) {
        self.init(descriptors: descriptors, payloadBuffer: payload.toRawPayloadBuffer())
    }
}
