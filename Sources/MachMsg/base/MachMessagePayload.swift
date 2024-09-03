import Foundation

/// A payload for a message.
public protocol MachMessagePayload: ContiguousBytes {
    /// An empty payload, to be filled with the raw bytes of a payload.
    static var empty: Self { get }
    /// Access the payload as a raw buffer pointer.
    /// - Parameter body: The closure to execute.
    /// - Returns: The result of the closure.
    func withUnsafeBytes<R>(_ body: (UnsafeRawBufferPointer) throws -> R) rethrows -> R
}

extension MachMessagePayload {
    public func withUnsafeBytes<R>(_ body: (UnsafeRawBufferPointer) throws -> R) rethrows -> R {
        try Swift.withUnsafeBytes(of: self, body)  // by default, use the object's own bytes
    }
}

/// A payload with a fixed length and trivial representation.
/// - Important: The payload must be trivial, i.e. it must not have any reference types.
#if swift(>=6.0)
    public protocol TrivialPayload: MachMessagePayload, BitwiseCopyable {}
#else
    public protocol TrivialPayload: MachMessagePayload {}
#endif
extension TrivialPayload {
    public static var empty: Self {
        assert(_isPOD(Self.self), "The payload type \(Self.self) is not trivial!")
        let buffer = UnsafeMutablePointer<Self>.allocate(capacity: 1)
        UnsafeMutableRawPointer(buffer).initializeMemory(
            as: UInt8.self, repeating: 0, count: MemoryLayout<Self>.size
        )
        return buffer.pointee
    }
}

/// A zero-length payload.
public struct ZeroLengthPayload: MachMessagePayload {
    public func withUnsafeBytes<R>(_ body: (UnsafeRawBufferPointer) throws -> R) rethrows -> R {
        try body(UnsafeRawBufferPointer(start: nil, count: 0))
    }
    public static var empty: ZeroLengthPayload { ZeroLengthPayload() }
}

extension Data: MachMessagePayload {
    public static var empty: Data { Data() }
}
