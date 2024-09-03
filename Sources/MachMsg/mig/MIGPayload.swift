import Foundation
import MachO

/// A payload for a MIG message.
public protocol MIGPayload: MachMessagePayload {}

/// A payload for a MIG message containing an NDR record.
public protocol MIGPayloadWithNDR: MIGPayload {
    /// The NDR record for the payload.
    /// - Important: The NDR record must be the first field in the payload.
    var NDR: NDR_record_t { get }
}

extension Data: MIGPayload {}
extension ZeroLengthPayload: MIGPayload {}
