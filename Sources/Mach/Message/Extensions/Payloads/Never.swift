/// A non-existent payload.
extension Never: Mach.Message.Payload {
    /// Return `nil`.
    /// - Parameter buffer: Ignored.
    /// - Returns: `nil`.
    public static func fromRawPayloadBuffer(_ buffer: UnsafeRawBufferPointer) -> Self? { nil }
    /// Return a zero-length empty buffer.
    /// - Returns: A zero-length empty buffer.
    public func toRawPayloadBuffer() -> UnsafeRawBufferPointer {
        UnsafeRawBufferPointer(start: nil, count: 0)
    }
}
