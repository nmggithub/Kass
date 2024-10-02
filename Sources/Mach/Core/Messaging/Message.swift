import Darwin.Mach

/// Message extensions.
extension Mach {
    /// A message.
    open class Message {
        /// The memory alignment of the message.
        internal static var alignment: Int { MemoryLayout<mach_msg_header_t>.alignment }

        /// The message header.
        public var header: mach_msg_header_t

        /// The message body.
        public var body: Mach.MessageBody?

        /// The message payload buffer.
        public var payload: UnsafeRawBufferPointer?

        /// The message trailer.
        public var trailer: mach_msg_max_trailer_t?

        /// The size of the message body.
        internal var bodySize: Int { body?.totalSize ?? 0 }

        /// The size of the message payload.
        internal var payloadSize: Int { payload?.count ?? 0 }

        /// The size of the message payload as advertised in the header.
        internal var advertisedPayloadSize: Int {
            Int(header.msgh_size) - MemoryLayout<mach_msg_header_t>.size - bodySize
        }

        /// The size of the message buffer.
        internal var bufferSize: Int {
            MemoryLayout<mach_msg_header_t>.size
                + self.bodySize
                + self.payloadSize
                + MemoryLayout<mach_msg_max_trailer_t>.size
        }

        /// Allocates a message buffer, serializes it with the message contents, and returns a header pointer.
        public func serialize() -> UnsafeMutablePointer<mach_msg_header_t> {
            // Allocate the buffer.
            let startPointer = UnsafeMutableRawPointer.allocate(
                byteCount: self.bufferSize, alignment: Self.alignment
            )

            // Create a mutable pointer to advance through the buffer.
            var serializingPointer = startPointer

            // Zero out the buffer.
            serializingPointer.initializeMemory(
                as: UInt8.self, repeating: 0, count: self.bufferSize
            )

            // Write the header.
            serializingPointer.bindMemory(to: mach_msg_header_t.self, capacity: 1).pointee =
                self.header  // This is pass-by-value, so we don't have to worry about what happens if `self.header` changes later.
            serializingPointer += MemoryLayout<mach_msg_header_t>.size

            // Write the body, if it exists.
            if let ownBody = self.body {
                let bodyPointer = serializingPointer.bindMemory(
                    to: mach_msg_body_t.self, capacity: 1
                )
                UnsafeMutableRawPointer(bodyPointer).copyMemory(
                    from: ownBody.serialize(),
                    byteCount: ownBody.totalSize
                )
                serializingPointer += ownBody.totalSize
            }

            // Write the payload, if it exists.
            if let ownPayloadBuffer = self.payload {
                ownPayloadBuffer.copyBytes(
                    to: UnsafeMutableRawBufferPointer(
                        start: serializingPointer, count: ownPayloadBuffer.count
                    )
                )
                serializingPointer += ownPayloadBuffer.count
            }

            // While convention might dictate that we keep this field set to zero for sent messages (as it is a kernel-set
            // field), we still need to be able to deserialize this raw representation back into a `MachMessage`. Thus, we
            // set it to what the kernel would set it to. The kernel allegedly ignores this field for sent messages, so it
            // should be safe to set it here. If the value is non-zero, we leave it as-is and assume it's purposeful.
            if self.header.msgh_size == 0 {
                // `serializingPointer` sould be at the end of the payload, so we can calculate the size of the message.
                let payloadEndPointer = serializingPointer
                self.header.msgh_size = mach_msg_size_t(payloadEndPointer - startPointer)
            }

            // Realign the pointer after writing an arbitrarily-sized payload.
            serializingPointer = serializingPointer.alignedUp(toMultipleOf: Self.alignment)

            // Write the trailer, if it exists.
            if let ownTrailer = self.trailer {
                serializingPointer.bindMemory(to: mach_msg_max_trailer_t.self, capacity: 1)
                    .pointee = ownTrailer
            }

            // Return a pointer to the start of the buffer (which should contain the header).
            return startPointer.bindMemory(to: mach_msg_header_t.self, capacity: 1)
        }

        /// Deserializes an existing message from a header pointer.
        public required init(headerPointer: UnsafeMutablePointer<mach_msg_header_t>) {
            // Create a mutable pointer to advance through the buffer.
            var deserializingPointer = UnsafeMutableRawPointer(headerPointer)

            // Read the header.
            self.header = headerPointer.pointee
            deserializingPointer += MemoryLayout<mach_msg_header_t>.size

            // Read the body, if it exists.
            self.body =
                switch self.header.bits.isMessageComplex {
                case false: nil
                case true:
                    Mach.MessageBody(
                        fromPointer: deserializingPointer.bindMemory(
                            to: mach_msg_body_t.self, capacity: 1
                        )
                    )
                }
            deserializingPointer += self.bodySize

            // Read the payload, if it exists.
            self.payload =
                switch self.advertisedPayloadSize {
                case 0: nil
                case let size:
                    UnsafeRawBufferPointer(
                        start: deserializingPointer, count: size
                    )
                }
            deserializingPointer += self.payloadSize

            // Read the trailer.
            // TODO: Determine if the trailer is always present.
            self.trailer = deserializingPointer.load(as: mach_msg_max_trailer_t.self)
        }

        /// Creates a message with a set of descriptors and a payload.
        public required init(
            descriptors: [any Mach.MessageDescriptor]? = nil,
            payloadBytes: UnsafeRawBufferPointer? = nil
        ) {
            self.header = mach_msg_header_t()
            if let descriptors = descriptors {
                self.body = Mach.MessageBody(descriptors: descriptors)
                self.header.bits.isMessageComplex = true
            }
            self.payload = payloadBytes
        }
    }
}
