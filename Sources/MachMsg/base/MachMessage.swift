import Darwin.Mach
import Foundation

extension MachMessage {
    /// The size of the message body.
    var bodySize: Int {
        body?.totalSize ?? 0
    }
    /// The size of the message payload.
    var payloadSize: Int {
        payload?.withUnsafeBytes { $0.count } ?? 0
    }
}

open class MachMessage<Payload: MachMessagePayload>: RawRepresentable {
    /// Represent the raw message as another message type.
    /// - Parameter type: The type to represent the raw message as.
    /// - Returns: The raw message, represented as the given type.
    public func `as`<
        AsPayload: MachMessagePayload,
        AsMessage: MachMessage<AsPayload>
    >(_ type: AsMessage.Type) -> AsMessage {
        type.init(rawValue: self.rawValue)
    }
    public typealias Header = MachMessageHeader
    public typealias Body = MachMessageBody

    /// The message header.
    public var header: Header
    /// The message body.
    public var body: Body?
    /// The message payload.
    public var payload: Payload?
    /// The message trailer.
    public var trailer: mach_msg_max_trailer_t?
    /// A pointer to the raw message.
    public var rawValue: UnsafeMutablePointer<mach_msg_header_t> {
        let bufferSize =
            MemoryLayout<mach_msg_header_t>.size
            + bodySize
            + payloadSize
            + MemoryLayout<mach_msg_max_trailer_t>.size
        var walkingPointer = UnsafeMutableRawPointer.allocate(byteCount: bufferSize, alignment: 1)
        walkingPointer.initializeMemory(as: UInt8.self, repeating: 0, count: bufferSize)
        let headerPointer = walkingPointer.bindMemory(to: mach_msg_header_t.self, capacity: 1)
        headerPointer.pointee = header.rawValue
        walkingPointer += MemoryLayout<mach_msg_header_t>.size
        let bodyPointer = walkingPointer.bindMemory(to: mach_msg_body_t.self, capacity: 1)
        if let body = body {
            UnsafeMutableRawPointer(bodyPointer).copyMemory(
                from: UnsafeRawPointer(body.rawValue),
                byteCount: body.totalSize
            )
        }
        if let payloadBufferPointer = payload?.withUnsafeBytes({ $0 }) {
            let payloadPointer = UnsafeMutableRawBufferPointer(
                start: walkingPointer, count: payloadBufferPointer.count
            )
            payloadBufferPointer.copyBytes(to: payloadPointer, count: payloadBufferPointer.count)
            walkingPointer += payloadBufferPointer.count
        }
        // The payload might not be aligned, so we need to add alignment padding
        walkingPointer = walkingPointer.alignedUp(
            toMultipleOf: MemoryLayout<mach_msg_header_t>.alignment
        )
        if let trailer = trailer {
            let trailerPointer = walkingPointer.bindMemory(
                to: mach_msg_max_trailer_t.self, capacity: 1
            )
            trailerPointer.pointee = trailer
        }
        return headerPointer
    }
    /// Represent an existing raw message.
    /// - Parameter rawValue: A pointer to the raw message.
    public required init(rawValue: UnsafeMutablePointer<mach_msg_header_t>) {
        var walkingPointer = UnsafeMutableRawPointer(rawValue)
        self.header = MachMessageHeader(rawValue: rawValue.pointee)
        walkingPointer += MemoryLayout<mach_msg_header_t>.size
        if self.header.bits.isMessageComplex {
            let bodyPointer = walkingPointer.bindMemory(to: mach_msg_body_t.self, capacity: 1)
            self.body = MachMessageBody(rawValue: bodyPointer)
            walkingPointer += self.body!.totalSize
        } else {
            self.body = nil
        }
        let payloadSize = Int(header.messageSize) - MemoryLayout<mach_msg_header_t>.size
        if payloadSize > 0 {
            let payloadBufferPointer = UnsafeMutableRawBufferPointer(
                start: walkingPointer, count: payloadSize
            )
            self.payload = Payload.empty
            self.payload?.withUnsafeBytes { (payloadPointer: UnsafeRawBufferPointer) in
                payloadBufferPointer.copyBytes(from: payloadPointer)
            }
            walkingPointer += payloadSize
        } else {
            self.payload = nil
        }
        let possibleTrailer = walkingPointer.bindMemory(
            to: mach_msg_max_trailer_t.self, capacity: 1
        ).pointee
        self.trailer = possibleTrailer.msgh_trailer_size > 0 ? possibleTrailer : nil
    }
    /// Create a message with a set of descriptors and a payload.
    /// - Parameters:
    ///   - descriptors: The descriptors to include in the message.
    ///   - payload: The payload to include in the message.
    public init(
        descriptors: [any MachMessageDescriptor]? = nil,
        payload: Payload? = nil
    ) {
        self.header = MachMessageHeader()
        if let descriptors = descriptors {
            self.body = MachMessageBody(descriptors: descriptors)
        }
        self.payload = payload
    }
}
