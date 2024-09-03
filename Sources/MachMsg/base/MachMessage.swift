import Darwin.Mach
import Foundation

extension MachMessage {
    /// The size of the message body.
    var bodySize: Int {
        body?.totalSize ?? 0
    }
    var payloadSize: Int {
        payloadBuffer?.count ?? 0
    }
}

open class MachMessage: RawRepresentable {
    public static var alignment: Int { MemoryLayout<mach_msg_header_t>.alignment }

    public typealias Header = MachMessageHeader
    public typealias Body = MachMessageBody

    /// The message header.
    public var header: Header
    /// The message body.
    public var body: Body?
    /// The message payload buffer.
    public var payloadBuffer: UnsafeRawBufferPointer?
    /// The message trailer.
    public var trailer: mach_msg_max_trailer_t?
    /// A pointer to the raw message.
    public var rawValue: UnsafeMutablePointer<mach_msg_header_t> {
        let rawBufferSize =
            MemoryLayout<mach_msg_header_t>.size
            + self.bodySize
            + self.payloadSize
            + MemoryLayout<mach_msg_max_trailer_t>.size
        var serializingPointer = UnsafeMutableRawPointer.allocate(
            byteCount: rawBufferSize, alignment: Self.alignment
        )
        serializingPointer.initializeMemory(as: UInt8.self, repeating: 0, count: rawBufferSize)  // Start with a zeroed-out buffer.
        let headerPointer = serializingPointer.bindMemory(to: mach_msg_header_t.self, capacity: 1)
        headerPointer.pointee = self.header.rawValue
        serializingPointer += MemoryLayout<mach_msg_header_t>.size
        let bodyPointer = serializingPointer.bindMemory(to: mach_msg_body_t.self, capacity: 1)
        if let body = self.body {
            UnsafeMutableRawPointer(bodyPointer).copyMemory(
                from: UnsafeRawPointer(body.rawValue),
                byteCount: body.totalSize
            )
            serializingPointer += body.totalSize
        }
        if let payloadBuffer = self.payloadBuffer {
            payloadBuffer.copyBytes(
                to: UnsafeMutableRawBufferPointer(
                    start: serializingPointer, count: payloadBuffer.count
                ))
            serializingPointer += payloadBuffer.count
        }
        // While convention might dictate that we keep this field set to zero for sent messages (as it is a kernel-set
        // field), we still need to be able to deserialize this raw representation back into a `MachMessage`. Thus, we
        // set it to what the kernel would set it to. The kernel allegedly ignores this field for sent messages, so it
        // should be safe to set it here. If the value is non-zero, we leave it as-is and assume it's purposeful.
        if headerPointer.pointee.msgh_size == 0 {
            // `serializingPointer` sould be at the end of the payload, so we can calculate the size of the message.
            let payloadEndPointer = serializingPointer
            headerPointer.pointee.msgh_size = mach_msg_size_t(
                payloadEndPointer - UnsafeMutableRawPointer(headerPointer)
            )
        }
        // We may not be aligned after writing the arbitrarily-sized payload, so we align up here before continuing.
        serializingPointer = serializingPointer.alignedUp(toMultipleOf: Self.alignment)
        if let trailer = trailer {
            let trailerPointer = serializingPointer.bindMemory(
                to: mach_msg_max_trailer_t.self, capacity: 1
            )
            trailerPointer.pointee = trailer
        }
        return headerPointer
    }
    /// Represent an existing raw message.
    /// - Parameter rawValue: A pointer to the raw message.
    public required init(rawValue: UnsafeMutablePointer<mach_msg_header_t>) {
        var deserializingPointer = UnsafeMutableRawPointer(rawValue)
        self.header = MachMessageHeader(rawValue: rawValue.pointee)
        deserializingPointer += MemoryLayout<mach_msg_header_t>.size
        if self.header.bits.isMessageComplex {
            let bodyPointer = deserializingPointer.bindMemory(to: mach_msg_body_t.self, capacity: 1)
            self.body = MachMessageBody(rawValue: bodyPointer)
            deserializingPointer += self.bodySize
        } else {
            self.body = nil
        }
        let rawPayloadSize =
            Int(header.messageSize)
            - MemoryLayout<mach_msg_header_t>.size
            - self.bodySize
        if rawPayloadSize > 0 {
            self.payloadBuffer = UnsafeRawBufferPointer(
                start: deserializingPointer, count: rawPayloadSize
            )
        } else {
            self.payloadBuffer = nil
        }
        let possibleTrailer = deserializingPointer.bindMemory(
            to: mach_msg_max_trailer_t.self, capacity: 1
        ).pointee
        self.trailer = possibleTrailer.msgh_trailer_size > 0 ? possibleTrailer : nil
    }
    /// Create a message with a set of descriptors and a payload.
    /// - Parameters:
    ///   - descriptors: The descriptors to include in the message.
    ///   - payloadBuffer: The payload buffer to include in the message.
    public required init(
        descriptors: [any MachMessageDescriptor]? = nil,
        payloadBuffer: UnsafeRawBufferPointer? = nil
    ) {
        self.header = MachMessageHeader()
        if let descriptors = descriptors {
            self.body = MachMessageBody(descriptors: descriptors)
            self.header.bits.isMessageComplex = true
        }
        self.payloadBuffer = payloadBuffer
    }

    /// Represent the raw message as another message type.
    /// - Parameter type: The type to represent the raw message as.
    /// - Returns: The raw message, represented as the given type.
    public func `as`<AsMessage: MachMessage>(_ type: AsMessage.Type) -> AsMessage {
        type.init(rawValue: self.rawValue)
    }

}

open class TypedMachMessage<Payload: MachMessagePayload>: MachMessage, WithTypedPayload {}
