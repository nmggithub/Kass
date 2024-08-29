import Darwin
import Foundation

/// A Mach message.
open class MachMessage<Payload> {
    /// The pointer to the start of the message buffer.
    internal let startPointer: UnsafeMutableRawPointer
    /// The header of the message.
    public let header: MachMessageHeader
    /// The descriptors for this message, if they exist.
    public let descriptors: MachMessageDescriptors?
    /// The size of the payload in bytes.
    public let payloadSize: Int
    /// The size of the message buffer in bytes.
    public let bufferSize: mach_msg_size_t
    /// The size of the message data in bytes.
    /// - Remark:
    ///     This specifically excludes the trailer, but also excludes any alignment padding
    ///     between the payload (or the header, if there is no payload) and the trailer. It
    ///     is calculated manually on initialization, and is the best guess as what will be
    ///     in the `mach_msg_size` field, inserted by the kernel, when the message is sent.
    public var messageSize: mach_msg_size_t {
        mach_msg_size_t(
            MemoryLayout<mach_msg_header_t>.size
                + (self.descriptors?.size ?? 0)
                + payloadSize
        )
    }
    /// The pointer to the payload of the message, if it exists.
    internal let payloadPointer: UnsafeMutablePointer<Payload>?
    /// The pointer to the trailer of the message
    private let trailerPointer: UnsafeMutablePointer<mach_msg_max_trailer_t>

    /// The message ID.
    public var id: mach_msg_id_t {
        get { self.header.messageID }
        set { self.header.messageID = newValue }
    }

    /// The size of the received message in bytes, excluding the trailer. It is 0 for sent messages.
    public var size: mach_msg_size_t {
        self.header.messageSize
    }

    /// The sending port of the message.
    public var localPort: MachMessagePort {
        get { self.header.localPort }
        set { self.header.localPort = newValue }
    }

    /// The receiving port of the message.
    public var remotePort: MachMessagePort {
        get { self.header.remotePort }
        set { self.header.remotePort = newValue }
    }

    /// The voucher port of the message.
    public var voucherPort: MachMessagePort {
        get { self.header.voucherPort }
        set { self.header.voucherPort = newValue }
    }

    public var voucher: MachVoucher? {
        get { MachVoucher(rawValue: self.voucherPort.rawValue) }
        set {
            self.voucherPort =
                newValue != nil
                // The kernel only accepts the voucher port if the disposition is `copySend` or `moveSend`. We
                // will use `copySend` here, as it is what the built-in `voucher_mach_msg_set` function uses.
                ? MachMessagePort(rawPort: newValue!.rawValue, disposition: .copySend)
                : MachMessagePort()
        }
    }

    /// Whether the message is complex (based on the header).
    public var isComplex: Bool {
        get { self.header.bits.other & MACH_MSGH_BITS_COMPLEX != 0 }
        set {
            if newValue {
                self.header.bits.other |= MACH_MSGH_BITS_COMPLEX
            } else {
                self.header.bits.other &= ~MACH_MSGH_BITS_COMPLEX
            }
        }
    }

    /// The payload for the message.
    public var payload: Payload? {
        get { self.payloadPointer?.pointee }
        set {
            guard self.payloadPointer != nil else { return }  // no-op if there is no payload
            guard newValue != nil else { return }  // no-op if newValue is nil
            self.payloadPointer!.pointee = newValue!
        }
    }

    public enum PayloadDataError: Swift.Error {
        /// The message is configured to have a typed payload. Use the `payload` property instead.
        case payloadIsTyped
        /// The message is not configured to have a payload.
        case noPayloadToSet
        /// The passed-in payload data is too large to fit in the message.
        case payloadTooLarge
    }

    /// Get the payload data as a `Data` object.
    /// - Throws: A `PayloadDataError` if the payload is typed, or if there is no payload to get.
    /// - Returns: The payload data as a `Data` object.
    public func getPayloadData() throws -> Data {
        guard Payload.self == Never.self else { throw PayloadDataError.payloadIsTyped }
        // These are both testing essentially the same thing (`payloadPointer` should not be
        // nil if the `payloadSize` is above zero), but it's still good to check.
        guard
            self.payloadPointer != nil,
            self.payloadSize > 0
        else { throw PayloadDataError.noPayloadToSet }
        return Data(bytes: self.payloadPointer!, count: self.payloadSize)
    }

    /// Set the payload data from a `Data` object.
    /// - Parameter payloadData: The payload data to set.
    /// - Throws: A `PayloadDataError` if the payload is typed, if there is no payload to set, or if the payload is too large.
    public func setPayloadData(_ payloadData: Data) throws {
        guard Payload.self == Never.self else { throw PayloadDataError.payloadIsTyped }
        // These are both testing essentially the same thing (`payloadPointer` should not be
        // nil if the `payloadSize` is above zero), but it's still good to check.
        guard
            self.payloadPointer != nil,
            self.payloadSize > 0
        else { throw PayloadDataError.noPayloadToSet }
        guard payloadData.count <= self.payloadSize else { throw PayloadDataError.payloadTooLarge }
        let rawPayloadPointer = UnsafeMutableRawPointer(self.payloadPointer!)
        // zero out the payload (in case the new data is smaller than the old data)
        rawPayloadPointer.initializeMemory(
            as: UInt8.self, repeating: 0, count: self.payloadSize
        )
        // copy the new data into the payload
        rawPayloadPointer.copyMemory(
            from: (payloadData as NSData).bytes, byteCount: Int(payloadSize)
        )
    }

    /// The trailer for the message.
    /// - Remark:
    ///     It appears that Mach may have used to allow more variety in the trailer, but now it's basically
    ///     guaranteed to be `mach_msg_max_trailer_t` (although some fields may be unused).
    public var trailer: mach_msg_max_trailer_t {
        get { self.trailerPointer.pointee }
        set { self.trailerPointer.pointee = newValue }
    }

    /// Create a new MachMessage with the given descriptor, payload, and trailer types. If you will
    /// be using an untyped payload, you must specify the size of the payload in bytes in lieu of a
    /// a payload type.
    /// - Parameters:
    ///   - payloadType: The type of the payload for the message.
    ///   - payloadSize: The size of the payload in bytes. Untyped payloads only (ignored if `payloadType` is specified).
    ///   - descriptorTypes: The types of the descriptors for the message.
    public init(
        descriptorTypes: [any MachMessageDescriptor.Type]? = nil,
        payloadType: Payload.Type = Never.self,
        payloadSize: Int? = nil
    ) {
        let alignment = MemoryLayout<mach_msg_header_t>.alignment  // TODO: check if this is the correct alignment
        let hasDescriptors = descriptorTypes != nil

        // calculate the size of the buffer

        var _bufferSize = MemoryLayout<mach_msg_header_t>.size
        if hasDescriptors {
            _bufferSize += MemoryLayout<mach_msg_body_t>.size
            let descriptorSize = descriptorTypes!.reduce(0) { $0 + $1.size }
            _bufferSize += descriptorSize
        }
        // the payload could be typed (via `Payload`), or untyped (via `payloadSize`), so get the appropriate size
        self.payloadSize =
            MemoryLayout<Payload>.size > 0
            ? MemoryLayout<Payload>.size
            : payloadSize ?? 0
        let distanceToPayload = _bufferSize
        _bufferSize += (self.payloadSize + alignment - 1) & ~(alignment - 1)  // add alignment bytes
        let distanceToTrailer = _bufferSize  // the trailer comes next, after the payload and alignment bytes
        _bufferSize += MemoryLayout<mach_msg_max_trailer_t>.size
        self.bufferSize = mach_msg_size_t(_bufferSize)

        self.startPointer = UnsafeMutableRawPointer.allocate(
            byteCount: Int(self.bufferSize), alignment: alignment
        )

        // set the pointers

        let headerPointer = self.startPointer.bindMemory(to: mach_msg_header_t.self, capacity: 1)
        self.header = MachMessageHeader(pointer: headerPointer)
        self.descriptors =
            hasDescriptors
            ? MachMessageDescriptors(
                bodyPointer: UnsafeMutableRawPointer(headerPointer + 1).bindMemory(
                    to: mach_msg_body_t.self, capacity: 1),
                types: descriptorTypes!)
            : nil
        self.payloadPointer =
            self.payloadSize > 0
            ? self.startPointer.advanced(by: distanceToPayload)
                .bindMemory(to: Payload.self, capacity: 1)
            : nil
        self.trailerPointer = self.startPointer.advanced(by: distanceToTrailer).bindMemory(
            to: mach_msg_max_trailer_t.self, capacity: 1
        )
        self.isComplex = hasDescriptors
    }

    /// Error that can occur when copying a message.
    public enum CopyError: Swift.Error {
        /// The message to copy in is larger than the message to be copied into.
        case cannotCopyInMessageOfLargerSize
    }

    /// Copy the contents of the given message into this message (allows message of any arbitrary type).
    /// - Parameter from: the message to copy from
    /// - Remark: If the `from` message contains data outside the bounds of what this message can hold, an error will be thrown.
    public func copyIn<FromPayload>(
        from: MachMessage<FromPayload>
    ) throws {
        if from.bufferSize > self.bufferSize {
            let extraDataPointer = from.startPointer.advanced(by: Int(self.bufferSize))
            let extraDataSize = from.bufferSize - self.bufferSize
            let extraData = UnsafeMutableBufferPointer(
                start: extraDataPointer.bindMemory(to: UInt8.self, capacity: Int(extraDataSize)),
                count: Int(extraDataSize)
            )
            // check if there is any actual data outside the bounds of what this message can hold
            guard extraData.allSatisfy({ $0 == 0 }) else {
                throw CopyError.cannotCopyInMessageOfLargerSize
            }

        }
        self.startPointer.copyMemory(from: from.startPointer, byteCount: Int(self.bufferSize))
    }
    /// Copy the contents of the given message into this message (only allows message of same type).
    /// - Parameter from: the message to copy from
    public func copyIn(from: MachMessage<Payload>) {
        self.startPointer.copyMemory(from: from.startPointer, byteCount: Int(self.bufferSize))
    }

    /// Cleans up the message buffer by zeroing out any extra data after the trailer.
    /// - Remark:
    ///     The Mach message system reuses the same buffer for sent messages and received messages. If you send a message of
    ///     a certain size, and then receive a message of a smaller size, the extra data from the sent message will still be
    ///     in the buffer. This method will zero out any data after the trailer, which should effectively zero out any extra
    ///     data left over from the sent message. This method is called automatically after a message is received, but it is
    ///     exposed here in case you need to manually clean up the buffer. Note that it really only makes sense to call this
    ///     method on received messages, as sent messages should not have any extra data in the buffer.
    public func cleanUpLeftoverData() {
        // get the pointer to the end of the buffer
        let endPointer = self.startPointer.advanced(by: Int(self.bufferSize))
        // get the actual size of the trailer (the type uses is `mach_msg_max_trailer_t`, but the actual size may be smaller)
        let trailerSize = self.trailer.msgh_trailer_size
        let extraDataPointer = UnsafeMutableRawPointer(self.trailerPointer)
            .advanced(by: Int(trailerSize))  // point to the first byte after the trailer
        let extraDataSize = endPointer - extraDataPointer  // the amount of extra data to zero out after the trailer
        extraDataPointer.initializeMemory(as: UInt8.self, repeating: 0, count: extraDataSize)  // zero out the data after the trailer
    }

    /// Attach the system voucher to the message (calls `voucher_mach_msg_set`).
    public func attatchVoucher() {
        voucher_mach_msg_set(self.header.pointer)
    }

    deinit {
        // This should also deallocate the memory pointed by the pointer in `header` and
        // `descriptors`. We don't deallocate that pointer directly, as it would cause a
        // double-free.
        self.startPointer.deallocate()
    }
}
