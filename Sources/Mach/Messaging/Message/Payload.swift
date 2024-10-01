import Foundation

/// MARK: - Message Payload
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
        var payload: PayloadType? { get set }
    }
}

extension Mach.MessageWithTypedPayload {
    /// The typed message payload.
    public var payload: PayloadType? {
        get {
            guard let payloadBuffer = payloadBuffer else { return nil }
            return PayloadType.fromRawPayloadBuffer(payloadBuffer)
        }
        set { payloadBuffer = newValue?.toRawPayloadBuffer() }
    }

    /// Creates a message with a set of descriptors and a payload.
    public init(
        descriptors: [any Mach.MessageDescriptor]? = nil,
        payload: PayloadType
    ) { self.init(descriptors: descriptors, payloadBuffer: payload.toRawPayloadBuffer()) }
}

/// MARK: - Trivial Payload
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
    /// - Parameter buffer: The raw buffer.
    /// - Returns: The `Data` payload, or `nil` if the buffer does not contain a valid payload.
    public static func fromRawPayloadBuffer(_ buffer: UnsafeRawBufferPointer) -> Self? {
        Self(buffer)
    }
    /// Converts the `Data` payload to a raw buffer.
    /// - Returns: The raw buffer.
    public func toRawPayloadBuffer() -> UnsafeRawBufferPointer {
        withUnsafeBytes {
            UnsafeRawBufferPointer(start: $0.baseAddress, count: $0.count)
        }
    }
}

// MARK: - Non-Existent Payload
/// A non-existent payload.
extension Never: Mach.MessagePayload {
    /// Returns `nil`.
    /// - Parameter buffer: Ignored.
    /// - Returns: `nil`.
    public static func fromRawPayloadBuffer(_ buffer: UnsafeRawBufferPointer) -> Self? { nil }
    /// Returns a zero-length empty buffer.
    /// - Returns: A zero-length empty buffer.
    public func toRawPayloadBuffer() -> UnsafeRawBufferPointer {
        UnsafeRawBufferPointer(start: nil, count: 0)
    }
}
