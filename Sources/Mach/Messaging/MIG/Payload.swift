import Darwin.Mach
import Foundation

extension Mach {
    /// A payload for a MIG message.
    public protocol MIGPayload: Mach.MessagePayload {}

    /// A payload for a MIG message containing an NDR record.
    public protocol PayloadWithNDR: Mach.MIGPayload {
        /// The NDR record for the payload.
        /// - Important: The NDR record must be the first field in the payload.
        var NDR: NDR_record_t { get }
    }

}

/// Data as a MIG payload.
extension Data: Mach.MIGPayload {}

/// A non-existent MIG payload.
extension Never: Mach.MIGPayload {}
