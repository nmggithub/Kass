import Foundation
import MachO

public protocol MIGPayload: MachMessagePayload {
    var NDR: NDR_record_t { get }
}
