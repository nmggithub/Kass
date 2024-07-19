import Darwin

/// A Mach message.
open class MachMessage<Payload> {
    /// The pointer to the start of the message buffer.
    internal let startPointer: UnsafeMutableRawPointer
    /// The header of the message.
    public let header: MachMessageHeader
    /// The descriptors for this message, if they exist.
    public let descriptors: MachMessageDescriptors?
    /// The size of the payload in bytes.
    private let payloadSize: Int
    /// The size of the message buffer in bytes.
    internal let bufferSize: mach_msg_size_t  // internal so that we can access it in the MachConnection class
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
    private let payloadPointer: UnsafeMutablePointer<Payload>?
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
    public var localPort: MachPort {
        get { self.header.localPort }
        set { self.header.localPort = newValue }
    }

    /// The receiving port of the message.
    public var remotePort: MachPort {
        get { self.header.remotePort }
        set { self.header.remotePort = newValue }
    }

    /// The voucher port of the message.
    public var voucherPort: MachPort {
        get { self.header.voucherPort }
        set { self.header.voucherPort = newValue }
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

    /// The trailer for the message.
    /// - Remark: It appears that Mach may have used to allow more variety in the trailer, but now it's
    /// basically guaranteed to be `mach_msg_max_trailer_t` (although some fields may be unused).
    public var trailer: mach_msg_max_trailer_t {
        get { self.trailerPointer.pointee }
        set { self.trailerPointer.pointee = newValue }
    }

    /// Create a new MachMessage with the given buffer size.
    /// - Parameter bufferSize: The size of the buffer in bytes.
    /// - Important: This must be used with a `Never`'ed constructor (e.g. `MachMessage<Never>(bufferSize: ...)`).
    convenience init(bufferSize: mach_msg_size_t = 0) {
        // guard the subtraction from underflowing and causing a crash
        let payloadSize =
            bufferSize >= mach_msg_size_t(MemoryLayout<mach_msg_header_t>.size)
            ? bufferSize - mach_msg_size_t(MemoryLayout<mach_msg_header_t>.size)
            : 0
        self.init(
            descriptorTypes: [],
            payloadType: Never.self as! Payload.Type,
            payloadSize: Int(payloadSize)
        )
    }

    /// Create a new MachMessage with the given descriptor, payload, and trailer types. If you will
    /// be using an untyped payload, you must specify the size of the payload in bytes in lieu of a
    /// a payload type.
    /// - Parameters:
    ///   - payloadType: The type of the payload for the message.
    ///   - payloadSize: The size of the payload in bytes. Untyped payloads only (ignored if `payloadType` is specified).
    ///   - trailerType: The type of the trailer for the message.
    ///   - descriptorTypes: The types of the descriptors for the message.
    public init(
        descriptorTypes: [any MachMessageDescriptor.Type] = [],
        payloadType: Payload.Type = Never.self,
        payloadSize: Int? = nil
    ) {
        let alignment = MemoryLayout<mach_msg_header_t>.alignment  // TODO: check if this is the correct alignment
        let hasDescriptors = descriptorTypes.count > 0

        var _bufferSize = MemoryLayout<mach_msg_header_t>.size
        if hasDescriptors {
            _bufferSize += MemoryLayout<mach_msg_body_t>.size
            let descriptorSize = descriptorTypes.reduce(0) { $0 + $1.size }
            _bufferSize += descriptorSize
        }
        // the payload could be typed (via `Payload`), or untyped (via `payloadSize`), so get the appropriate size
        self.payloadSize =
            MemoryLayout<Payload>.size > 0
            ? MemoryLayout<Payload>.size
            : payloadSize ?? 0
        let distanceToPayload = _bufferSize
        _bufferSize += (self.payloadSize + alignment - 1) & ~(alignment - 1)  // align the payload
        let distanceToTrailer = _bufferSize
        _bufferSize += MemoryLayout<mach_msg_max_trailer_t>.size
        self.bufferSize = mach_msg_size_t(_bufferSize)

        self.startPointer = UnsafeMutableRawPointer.allocate(
            byteCount: Int(self.bufferSize), alignment: alignment
        )
        let headerPointer = self.startPointer.bindMemory(to: mach_msg_header_t.self, capacity: 1)
        self.header = MachMessageHeader(pointer: headerPointer)
        self.descriptors =
            hasDescriptors
            ? MachMessageDescriptors(
                bodyPointer: UnsafeMutableRawPointer(headerPointer + 1).bindMemory(
                    to: mach_msg_body_t.self, capacity: 1),
                types: descriptorTypes)
            : nil
        self.payloadPointer =
            self.payloadSize > 0
            ? self.startPointer.advanced(by: distanceToPayload)
                .bindMemory(to: Payload.self, capacity: 1)
            : nil
        self.trailerPointer = self.startPointer.advanced(by: distanceToTrailer).bindMemory(
            to: mach_msg_max_trailer_t.self, capacity: 1
        )
    }

    /// Error that can occur when copying a message.
    enum CopyError: Swift.Error {
        /// The message to copy in is larger than the message to be copied into.
        case cannotCopyInMessageOfLargerSize
        // The payload is too large to fit in the message.
        case payloadTooLarge
    }

    /// Set the payload of the message to the given value.
    /// - Parameters:
    ///   - bytes: The bytes to set the payload to.
    ///   - count: The number of bytes in the payload.
    /// - Remark: This method is meant for variable-length payloads, which are not supported if the message has a typed payload with a non-zero size.
    public func setPayloadBytes(_ bytes: UnsafeRawPointer, count: Int) throws {
        guard MemoryLayout<Payload>.size == 0 else { return }
        let maxPayloadSize =
            bufferSize - mach_msg_size_t(MemoryLayout<mach_msg_header_t>.stride)
        guard count <= maxPayloadSize else { throw CopyError.payloadTooLarge }
        UnsafeMutableRawPointer(self.payloadPointer!).copyMemory(from: bytes, byteCount: count)
    }

    /// Get the payload of the message as a buffer of bytes.
    /// - Returns: The payload as a buffer of bytes, or `nil` if the payload is typed.
    /// - Remark: This method is meant for variable-length payloads, which are not supported if the message has a typed payload with a non-zero size.
    public func getPayloadBytes() -> UnsafeRawBufferPointer? {
        guard MemoryLayout<Payload>.size == 0 else { return nil }
        return UnsafeRawBufferPointer(start: self.payloadPointer!, count: self.payloadSize)
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
