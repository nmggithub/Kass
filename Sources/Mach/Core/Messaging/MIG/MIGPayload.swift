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

    /// A payload for a MIG message containing multiple contiguous sub-payloads.
    /// - Warning: This cannot be used for received messages, as the sub-payloads are not easily recoverable.
    public struct MIGPayloadWithMultipleContiguousSubPayloads: Mach.MIGPayload {
        public static func fromRawPayloadBuffer(_ buffer: UnsafeRawBufferPointer)
            -> Mach.MIGPayloadWithMultipleContiguousSubPayloads?
        {
            // It's not really possible to recover the sub-payloads from the buffer, as they could be anything.
            return nil
        }

        public func toRawPayloadBuffer() -> UnsafeRawBufferPointer {
            let buffers = subPayloads.map { $0.toRawPayloadBuffer() }
            let resultBuffer = UnsafeMutableRawBufferPointer.allocate(
                byteCount: buffers.reduce(0) { $0 + ($1.count + 3) & ~3 },
                alignment: 4
            )
            var offset = 0
            for buffer in buffers {
                resultBuffer.baseAddress!.advanced(by: offset).copyMemory(
                    from: buffer.baseAddress!,
                    byteCount: buffer.count
                )
                offset += (buffer.count + 3) & ~3
            }
            return UnsafeRawBufferPointer(resultBuffer)
        }

        public let subPayloads: [Mach.MIGPayload]

        public init(_ payloads: [Mach.MIGPayload]) {
            self.subPayloads = payloads
        }
    }

    public struct MIGPayloadWithVariableLengthCString: Mach.MIGPayload {
        /// The string.
        public let string: String

        /// Initializes a payload with the given string.
        public init(string: String) {
            self.string = string
        }

        public static func fromRawPayloadBuffer(_ buffer: UnsafeRawBufferPointer) -> Mach
            .MIGPayloadWithVariableLengthCString?
        {
            guard let baseAddress = buffer.baseAddress else { return nil }
            let recoveredString = String(
                cString: baseAddress.bindMemory(to: CChar.self, capacity: buffer.count)
            )
            return MIGPayloadWithVariableLengthCString(string: recoveredString)
        }

        public func toRawPayloadBuffer() -> UnsafeRawBufferPointer {
            let stringCString = string.cString(using: .utf8)!
            let buffer = UnsafeMutableRawBufferPointer.allocate(
                byteCount: stringCString.count, alignment: 4
            )
            buffer.baseAddress!.copyMemory(from: stringCString, byteCount: stringCString.count)
            return UnsafeRawBufferPointer(buffer)
        }
    }
}

/// Data as a MIG payload.
extension Data: Mach.MIGPayload {}

/// A non-existent MIG payload.
extension Never: Mach.MIGPayload {}
