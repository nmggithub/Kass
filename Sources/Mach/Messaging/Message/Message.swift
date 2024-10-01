import Darwin.Mach
@_exported import MachCore

/// Message extensions.
extension Mach {
    /// A message.
    open class Message: RawRepresentable {
        /// The memory alignment of the message.
        internal static var alignment: Int { MemoryLayout<mach_msg_header_t>.alignment }

        /// The message header.
        public var header: mach_msg_header_t

        /// The message body.
        public var body: Mach.MessageBody?

        /// The message payload buffer.
        public var payloadBuffer: UnsafeRawBufferPointer?

        /// The message trailer.
        public var trailer: Trailer?

        /// The size of the message body.
        var bodySize: Int {
            body?.totalSize ?? 0
        }

        /// The size of the message payload.
        var payloadSize: Int {
            payloadBuffer?.count ?? 0
        }

        /// A pointer to a raw representation of the message.
        public var rawValue: UnsafeMutablePointer<mach_msg_header_t> {
            let rawBufferSize =
                MemoryLayout<mach_msg_header_t>.size
                + self.bodySize
                + self.payloadSize
                + MemoryLayout<Trailer.RawValue>.size
            var serializingPointer = UnsafeMutableRawPointer.allocate(
                byteCount: rawBufferSize, alignment: Self.alignment
            )
            serializingPointer.initializeMemory(as: UInt8.self, repeating: 0, count: rawBufferSize)  // Start with a zeroed-out buffer.
            let headerPointer = serializingPointer.bindMemory(
                to: mach_msg_header_t.self, capacity: 1)
            headerPointer.pointee = self.header  // This is pass-by-value, so we don't have to worry about what happens if `self.header` changes later.
            serializingPointer += MemoryLayout<mach_msg_header_t>.size
            let bodyPointer = serializingPointer.bindMemory(to: mach_msg_body_t.self, capacity: 1)
            if let ownBodyPointer = self.body?.pointer {
                UnsafeMutableRawPointer(bodyPointer).copyMemory(
                    from: ownBodyPointer.baseAddress!,  // We control `Mach.MessageBody.pointer`, so we know it's safe to force-unwrap.
                    byteCount: ownBodyPointer.count
                )
                serializingPointer += ownBodyPointer.count
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
                trailerPointer.pointee = trailer.rawValue
            }
            return headerPointer
        }

        /// Represents an existing raw message.
        public required init(rawValue: UnsafeMutablePointer<mach_msg_header_t>) {
            var deserializingPointer = UnsafeMutableRawPointer(rawValue)
            self.header = rawValue.pointee
            deserializingPointer += MemoryLayout<mach_msg_header_t>.size
            if self.header.bits.isMessageComplex {
                let bodyPointer = deserializingPointer.bindMemory(
                    to: mach_msg_body_t.self, capacity: 1
                )
                self.body = Mach.MessageBody(fromPointer: bodyPointer)
                deserializingPointer += self.bodySize
            } else {
                self.body = nil
            }
            let rawPayloadSize =
                Int(header.msgh_size)
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
            self.trailer =
                possibleTrailer.msgh_trailer_size > 0 ? Trailer(rawValue: possibleTrailer) : nil
        }

        /// Creates a message with a set of descriptors and a payload.
        public required init(
            descriptors: [any Mach.MessageDescriptor]? = nil,
            payloadBuffer: UnsafeRawBufferPointer? = nil
        ) {
            self.header = mach_msg_header_t()
            if let descriptors = descriptors {
                self.body = Mach.MessageBody(descriptors: descriptors)
                self.header.bits.isMessageComplex = true
            }
            self.payloadBuffer = payloadBuffer
        }
    }
}
