import Foundation

/// Data as a message payload.
extension Data: Mach.Message.Payload {
    /// Load a `Data` payload from a raw buffer.
    /// - Parameter buffer: The raw buffer.
    /// - Returns: The `Data` payload, or `nil` if the buffer does not contain a valid payload.
    public static func fromRawPayloadBuffer(_ buffer: UnsafeRawBufferPointer) -> Self? {
        Self(buffer)
    }
    /// Convert the `Data` payload to a raw buffer.
    /// - Returns: The raw buffer.
    public func toRawPayloadBuffer() -> UnsafeRawBufferPointer {
        withUnsafeBytes {
            UnsafeRawBufferPointer(start: $0.baseAddress, count: $0.count)
        }
    }
}
