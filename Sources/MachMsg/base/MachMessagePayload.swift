import Foundation

/// A payload for a message.
public protocol MachMessagePayload {
    /// Load a payload from a raw buffer.
    /// - Parameter buffer: The raw buffer.
    /// - Returns: The payload, or `nil` if the buffer does not contain a valid payload of this type.
    static func fromRawPayloadBuffer(_ buffer: UnsafeRawBufferPointer) -> Self?
    /// Convert the payload to a raw buffer.
    /// - Returns: The raw buffer.
    func toRawPayloadBuffer() -> UnsafeRawBufferPointer
}

/// A payload with a fixed length and trivial representation.
/// - Important: The payload must be trivial, i.e. it must not have any reference types.
#if swift(>=6.0)
    public protocol TrivialPayload: MachMessagePayload, BitwiseCopyable {}
#else
    public protocol TrivialPayload: MachMessagePayload {}
#endif

extension TrivialPayload {
    public static func fromRawPayloadBuffer(_ buffer: UnsafeRawBufferPointer) -> Self? {
        #if swift(<6)
            assert(
                _isPOD(Self.self),
                """
                Cannot load payload of type \(Self.self) from buffer. It was declared to conform to \
                TrivialPayload, but is not a POD type.
                """
            )
        #endif
        guard buffer.count == MemoryLayout<Self>.size else { return nil }
        return buffer.load(as: Self.self)
    }
    public func toRawPayloadBuffer() -> UnsafeRawBufferPointer {
        withUnsafeBytes(of: self) {
            UnsafeRawBufferPointer(start: $0.baseAddress, count: $0.count)
        }
    }
}

extension Never: MachMessagePayload {
    public static func fromRawPayloadBuffer(_ buffer: UnsafeRawBufferPointer) -> Self? { nil }
    public func toRawPayloadBuffer() -> UnsafeRawBufferPointer {
        UnsafeRawBufferPointer(start: nil, count: 0)
    }
}

extension Data: MachMessagePayload {
    public static func fromRawPayloadBuffer(_ buffer: UnsafeRawBufferPointer) -> Self? {
        Self(buffer)
    }
    public func toRawPayloadBuffer() -> UnsafeRawBufferPointer {
        withUnsafeBytes {
            UnsafeRawBufferPointer(start: $0.baseAddress, count: $0.count)
        }
    }
}

/// A message with a typed payload.
public protocol WithTypedPayload: MachMessage {
    associatedtype Payload: MachMessagePayload
    /// The typed message payload.
    var payload: Payload? { get }

}

extension WithTypedPayload {
    /// The typed message payload.
    public var payload: Payload? {
        get {
            guard let payloadBuffer = payloadBuffer else { return nil }
            return Payload.fromRawPayloadBuffer(payloadBuffer)
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
        descriptors: [any MachMessageDescriptor]? = nil,
        payload: Payload
    ) {
        self.init(descriptors: descriptors, payloadBuffer: payload.toRawPayloadBuffer())
    }
}
