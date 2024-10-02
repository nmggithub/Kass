import Foundation

// MARK: - Message Payload
extension Mach {
    /// A message payload.
    public protocol MessagePayload {
        /// Loads a payload from a raw buffer.
        static func fromRawPayloadBuffer(_ buffer: UnsafeRawBufferPointer) -> Self?

        /// Converts the payload to a raw buffer.
        func toRawPayloadBuffer() -> UnsafeRawBufferPointer
    }

    /// A message with a typed payload.
    public protocol MessageWithTypedPayload: Mach.Message {
        associatedtype PayloadType: Mach.MessagePayload
        /// The typed message payload.
        var typedPayload: PayloadType? { get set }
    }
}

extension Mach.MessageWithTypedPayload {
    /// The typed message payload.
    public var typedPayload: PayloadType? {
        get {
            guard let payloadBuffer = payload else { return nil }
            return PayloadType.fromRawPayloadBuffer(payloadBuffer)
        }
        set { payload = newValue?.toRawPayloadBuffer() }
    }

    /// Creates a message with a set of descriptors and a payload.
    public init(
        descriptors: [any Mach.MessageDescriptor]? = nil,
        payload: PayloadType
    ) { self.init(descriptors: descriptors, payloadBytes: payload.toRawPayloadBuffer()) }
}

// MARK: - Trivial Payload
extension Mach {
    /// A payload with a fixed length and trivial representation.
    public protocol TrivialMessagePayload: Mach.MessagePayload, BitwiseCopyable {}
}

extension Mach.TrivialMessagePayload {
    public static func fromRawPayloadBuffer(_ buffer: UnsafeRawBufferPointer) -> Self? {
        guard buffer.count == MemoryLayout<Self>.size else { return nil }
        return buffer.load(as: Self.self)
    }

    public func toRawPayloadBuffer() -> UnsafeRawBufferPointer {
        return withUnsafeBytes(of: self) {
            UnsafeRawBufferPointer(start: $0.baseAddress, count: $0.count)
        }
    }
}

// MARK: - Data Payload
/// Data as a message payload.
extension Data: Mach.MessagePayload {
    /// Loads a `Data` payload from a raw buffer.
    public static func fromRawPayloadBuffer(_ buffer: UnsafeRawBufferPointer) -> Self? {
        Self(buffer)
    }

    /// Converts the `Data` payload to a raw buffer.
    public func toRawPayloadBuffer() -> UnsafeRawBufferPointer {
        self.withUnsafeBytes {
            dataBuffer in
            let buffer = UnsafeMutableRawBufferPointer.allocate(
                byteCount: dataBuffer.count,
                // This is going into a message, so it should be aligned to the message alignment.
                alignment: Mach.Message.alignment
            )
            buffer.copyMemory(from: dataBuffer)
            return UnsafeRawBufferPointer(buffer)
        }
    }
}

// MARK: - Non-Existent Payload
/// A non-existent payload.
extension Never: Mach.MessagePayload {
    /// Returns `nil`.
    public static func fromRawPayloadBuffer(_ buffer: UnsafeRawBufferPointer) -> Self? { nil }

    /// Returns a zero-length empty buffer.
    public func toRawPayloadBuffer() -> UnsafeRawBufferPointer {
        UnsafeRawBufferPointer(start: nil, count: 0)
    }
}
