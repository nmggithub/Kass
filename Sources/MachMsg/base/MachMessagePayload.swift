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
public protocol FixedLengthTrivialPayload: MachMessagePayload {}
extension FixedLengthTrivialPayload {
    public static var empty: Self {
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
