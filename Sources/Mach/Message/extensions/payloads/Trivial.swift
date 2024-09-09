extension Mach.Message.Payload {
    /// A payload with a fixed length and trivial representation.
    public typealias Trivial = Mach.Message.TrivialPayload
}
extension Mach.Message {
    #if swift(>=6.0)
        /// A payload with a fixed length and trivial representation.
        public protocol TrivialPayload: Mach.Message.TypedPayload, BitwiseCopyable {}
    #else
        /// A payload with a fixed length and trivial representation.
        /// - Important: The payload must be trivial, i.e. it must not have any reference types.
        public protocol TrivialPayload: Mach.Message.Payload {}
    #endif
}

extension Mach.Message.TrivialPayload {
    public static func fromRawPayloadBuffer(_ buffer: UnsafeRawBufferPointer) -> Self? {
        #if swift(<6)
            assert(
                _isPOD(Self.self),
                """
                Cannot load payload of type `\(Self.self)` from buffer. It was
                declared to conform to `TrivialPayload`, but is not a POD type.
                """
            )
        #endif
        guard buffer.count == MemoryLayout<Self>.size else { return nil }
        return buffer.load(as: Self.self)
    }
    public func toRawPayloadBuffer() -> UnsafeRawBufferPointer {
        #if swift(<6)
            assert(
                _isPOD(Self.self),
                """
                Cannot store payload of type `\(Self.self)` in buffer. It was
                declared to conform to `TrivialPayload`, but is not a POD type.
                """
            )
        #endif
        return withUnsafeBytes(of: self) {
            UnsafeRawBufferPointer(start: $0.baseAddress, count: $0.count)
        }
    }
}
