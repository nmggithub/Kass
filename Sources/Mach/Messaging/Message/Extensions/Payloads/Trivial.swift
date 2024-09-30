extension Mach.Message.Payload {
    /// A payload with a fixed length and trivial representation.
    public typealias Trivial = Mach.Message.TrivialPayload
}
extension Mach.Message {
    /// A payload with a fixed length and trivial representation.
    public protocol TrivialPayload: Mach.Message.Payload, BitwiseCopyable {}
}

extension Mach.Message.TrivialPayload {
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
