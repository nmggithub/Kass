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
        let newBufferSize =
            MemoryLayout<mach_msg_header_t>.size
            + self.bodySize
            + self.payloadSize
            + MemoryLayout<mach_msg_max_trailer_t>.size
        var serializingPointer = UnsafeMutableRawPointer.allocate(
            byteCount: newBufferSize, alignment: Self.alignment
        )
        serializingPointer.initializeMemory(as: UInt8.self, repeating: 0, count: newBufferSize)
        let headerPointer = serializingPointer.bindMemory(to: mach_msg_header_t.self, capacity: 1)
        headerPointer.pointee = header.rawValue
        serializingPointer += MemoryLayout<mach_msg_header_t>.size
        let bodyPointer = serializingPointer.bindMemory(to: mach_msg_body_t.self, capacity: 1)
        if let body = body {
            UnsafeMutableRawPointer(bodyPointer).copyMemory(
                from: UnsafeRawPointer(body.rawValue),
                byteCount: body.totalSize
            )
            serializingPointer += body.totalSize
        }
        if let payloadBuffer = payloadBuffer {
            payloadBuffer.copyBytes(
                to: UnsafeMutableRawBufferPointer(
                    start: serializingPointer, count: payloadBuffer.count
                ))
            serializingPointer += payloadBuffer.count
        }
        // The payload might not be aligned, so we need to add alignment padding
        serializingPointer = serializingPointer.alignedUp(
            toMultipleOf: MemoryLayout<mach_msg_header_t>.alignment
        )
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
    public init(
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

open class TypedMachMessage<Payload: MachMessagePayload>: MachMessage, WithTypedPayload {
    /// The message payload.
    public var payload: Payload? {
        get {
            guard let payloadBuffer = payloadBuffer else { return nil }
            return Payload.fromRawPayloadBuffer(payloadBuffer)
        }
        set {
            payloadBuffer = newValue?.toRawPayloadBuffer()
        }
    }
    /// Create a message with a set of descriptors and a payload.
    /// - Parameters:
    ///   - descriptors: The descriptors to include in the message.
    ///   - payload: The payload to include in the message.
    public convenience init(
        descriptors: [any MachMessageDescriptor]? = nil,
        payload: Payload
    ) {
        self.init(descriptors: descriptors, payloadBuffer: payload.toRawPayloadBuffer())
    }
}
