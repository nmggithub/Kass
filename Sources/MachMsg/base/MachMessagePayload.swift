import Foundation

/// A payload for a message.
public protocol MachMessagePayload {
    static func fromRawPayloadBuffer(_ buffer: UnsafeRawBufferPointer) -> Self
}

/// A payload with a fixed length and trivial representation.
/// - Important: The payload must be trivial, i.e. it must not have any reference types.
#if swift(>=6.0)
    public protocol TrivialPayload: MachMessagePayload, BitwiseCopyable {}
#else
    public protocol TrivialPayload: MachMessagePayload {}
#endif

extension TrivialPayload {
    public static func fromRawPayloadBuffer(_ buffer: UnsafeRawBufferPointer) -> Self {
        #if swift(<6)
            assert(
                _isPOD(Self.self),
                """
                Cannot load payload of type \(Self.self) from buffer. It was declared to conform to \
                TrivialPayload, but is not a POD type.
                """
            )
        #endif
        guard buffer.count == MemoryLayout<Self>.size else {
            fatalError(
                """
                Cannot load payload of type \(Self.self) from buffer. \(Self.self) has a fixed size of \
                \(MemoryLayout<Self>.size) bytes, but the buffer has a size of \(buffer.count) bytes.
                """)
        }
        return buffer.load(as: Self.self)
    }
}

extension Never: MachMessagePayload {
    public static func fromRawPayloadBuffer(_ buffer: UnsafeRawBufferPointer) -> Self {
        fatalError("Cannot load payload of type Never from buffer.")
    }
}

extension Data: MachMessagePayload {
    public static func fromRawPayloadBuffer(_ buffer: UnsafeRawBufferPointer) -> Self {
        Self(buffer)
    }
}
