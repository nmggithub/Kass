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
    public struct MIGPayloadWithOnlyNDR: Mach.MIGPayloadWithNDR {
        public var NDR: NDR_record_t
    }

    /// A payload for a MIG message containing a variable-length string.
    public struct MIGPayloadWithVariableLengthString<
        Before: BitwiseCopyable, After: BitwiseCopyable
    >: Mach.MessagePayload, Mach.MIGPayload {
        /// The part of the payload before the string.
        public let before: Before

        /// The string itself.
        public let string: String

        /// The part of the payload after the string.
        public let after: After

        /// Initializes a payload with the given parts.
        public init(before: Before, string: String, after: After) {
            self.before = before
            self.string = string
            self.after = after
        }

        public static func fromRawPayloadBuffer(_ buffer: UnsafeRawBufferPointer)
            -> MIGPayloadWithVariableLengthString?
        {
            guard let baseAddress = buffer.baseAddress else { return nil }
            let recoveredBefore = baseAddress.load(as: Before.self)
            let stringStart = baseAddress.advanced(by: MemoryLayout<Before>.size)
            let recoveredString = String(
                cString: stringStart.bindMemory(to: CChar.self, capacity: 1))
            let afterString = stringStart.advanced(by: (recoveredString.count + 3) & ~3)
            let recoveredAfter = afterString.load(as: After.self)
            return MIGPayloadWithVariableLengthString(
                before: recoveredBefore, string: recoveredString, after: recoveredAfter
            )
        }

        public func toRawPayloadBuffer() -> UnsafeRawBufferPointer {
            let stringCString = string.cString(using: .utf8)!
            let buffer = UnsafeMutableRawBufferPointer.allocate(
                byteCount: MemoryLayout<Before>.size + stringCString.count
                    + MemoryLayout<After>.size,
                alignment: 4
            )
            buffer.baseAddress!.storeBytes(of: before, as: Before.self)
            let stringStart = buffer.baseAddress!.advanced(by: MemoryLayout<Before>.size)
            stringStart.copyMemory(from: stringCString, byteCount: stringCString.count)
            let afterString = stringStart.advanced(by: (stringCString.count + 3) & ~3)
            afterString.storeBytes(of: after, as: After.self)
            return UnsafeRawBufferPointer(buffer)
        }
    }
}

/// Data as a MIG payload.
extension Data: Mach.MIGPayload {}

/// A non-existent MIG payload.
extension Never: Mach.MIGPayload {}
