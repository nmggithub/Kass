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

    /// A payload for a MIG message containing an NDR record and an inner payload.
    public struct MIGPayloadPrefixedWithNDR<InnerPayload: BitwiseCopyable>: Mach.MIGPayload {

        /// The NDR record for the payload.
        public let NDR: NDR_record_t

        /// The inner payload.
        public let innerPayload: InnerPayload

        /// Creates a new payload with an NDR record and an inner payload.
        public init(
            NDR: NDR_record_t = NDR_record_t(),
            innerPayload: InnerPayload
        ) {
            self.NDR = NDR
            self.innerPayload = innerPayload
        }

        public static func fromRawPayloadBuffer(
            _ buffer: UnsafeRawBufferPointer
        ) -> Mach.MIGPayloadPrefixedWithNDR<InnerPayload>? {
            let ndr = buffer.load(fromByteOffset: 0, as: NDR_record_t.self)
            let innerPayload = buffer.load(
                fromByteOffset: MemoryLayout<NDR_record_t>.size, as: InnerPayload.self)
            return Self(NDR: ndr, innerPayload: innerPayload)
        }

        public func toRawPayloadBuffer() -> UnsafeRawBufferPointer {
            let size = MemoryLayout<NDR_record_t>.size + MemoryLayout<InnerPayload>.size
            let buffer = UnsafeMutableRawBufferPointer.allocate(
                byteCount: size,
                alignment: MemoryLayout<InnerPayload>.alignment
            )
            buffer.storeBytes(of: NDR, toByteOffset: 0, as: NDR_record_t.self)
            buffer.storeBytes(
                of: innerPayload,
                toByteOffset: MemoryLayout<NDR_record_t>.size,
                as: InnerPayload.self
            )
            return UnsafeRawBufferPointer(buffer)
        }
    }

    /// A payload for a MIG message containing only an NDR record.
    public struct MIGPayloadWithOnlyNDR: Mach.MIGPayloadWithNDR {
        public var NDR: NDR_record_t
        public init(NDR: NDR_record_t) {
            self.NDR = NDR
        }
    }
}

/// Data as a MIG payload.
extension Data: Mach.MIGPayload {}

/// A non-existent MIG payload.
extension Never: Mach.MIGPayload {}

/// A message payload with segments as a MIG payload.
extension Mach.MessagePayloadWithSegments: Mach.MIGPayload {}
