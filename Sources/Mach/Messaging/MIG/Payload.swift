import Darwin.Mach
import Foundation

extension Mach.Message.MIG {
    /// A payload for a MIG message.
    public protocol Payload: Mach.Message.Payload {}

    /// A payload for a MIG message containing an NDR record.
    public protocol PayloadWithNDR: Payload {
        /// The NDR record for the payload.
        /// - Important: The NDR record must be the first field in the payload.
        var NDR: NDR_record_t { get }
    }

}

/// Data as a MIG payload.
extension Data: Mach.Message.MIG.Payload {}
/// A non-existent MIG payload.
extension Never: Mach.Message.MIG.Payload {}
