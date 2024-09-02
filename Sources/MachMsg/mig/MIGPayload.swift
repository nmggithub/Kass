import Foundation
import MachO

/// A payload for a MIG message.
public protocol MIGPayload: MachMessagePayload {}

/// An empty payload.
public struct EmptyMIGPayload: MIGPayload {
    public func withUnsafeBytes<R>(_ body: (UnsafeRawBufferPointer) throws -> R) rethrows -> R {
        try body(UnsafeRawBufferPointer(start: nil, count: 0))  // pass an empty buffer
    }
    public init() {}
}

/// A payload for a MIG message containing an NDR record.
public protocol MIGPayloadWithNDR: MIGPayload {
    /// The NDR record for the payload.
    /// - Important: The NDR record must be the first field in the payload.
    var NDR: NDR_record_t { get }
}
