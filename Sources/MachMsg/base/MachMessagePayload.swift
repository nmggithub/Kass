import Foundation

/// A payload for a message.
public protocol MachMessagePayload: ContiguousBytes {
    init()
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

/// An empty payload.
public struct EmptyMachMessagePayload: MachMessagePayload {
    public func withUnsafeBytes<R>(_ body: (UnsafeRawBufferPointer) throws -> R) rethrows -> R {
        try body(UnsafeRawBufferPointer(start: nil, count: 0))  // pass an empty buffer
    }
    public init() {}
}

/// A payload with an external representation.
public protocol MachMessageExternalPayload: MachMessagePayload {
    /// The external representation of the payload.
    var external: ContiguousBytes { get set }
}

extension MachMessageExternalPayload {
    public func withUnsafeBytes<R>(_ body: (UnsafeRawBufferPointer) throws -> R) rethrows -> R {
        try self.external.withUnsafeBytes(body)  // use the external representation's bytes
    }
}

extension Data: MachMessagePayload {}  // Data can be used as a payload
