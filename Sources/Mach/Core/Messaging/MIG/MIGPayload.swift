import Darwin.Mach
import Foundation

extension Mach {
    /// A payload for a MIG message.
    public protocol MIGPayload: Mach.MessagePayload {}

    /// A payload for a MIG message containing an NDR record.
    /// - Important: The NDR record must be the first field in the payload.
    public protocol MIGPayloadWithNDR: Mach.MIGPayload, Mach.TrivialMessagePayload {
        /// The NDR record for the payload.
        var NDR: NDR_record_t { get }
    }

    /// A payload for a MIG message containing only an NDR record.
    struct MIGPayloadWithOnlyNDR: Mach.MIGPayloadWithNDR {
        var NDR: NDR_record_t
    }
}

/// Data as a MIG payload.
extension Data: Mach.MIGPayload {}

/// A non-existent MIG payload.
extension Never: Mach.MIGPayload {}
