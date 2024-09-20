import Darwin.Mach

extension Mach.Message.Server {
    /// A peeked preview of a message.
    public struct PeekedMessage {
        /// The advertised message size.
        public var size: mach_msg_size_t
        /// The message ID.
        public var id: mach_msg_id_t
        /// The trailer.
        public var trailer: mach_msg_max_trailer_t
    }
    /// Peeks at the message in the queue with the given sequence number, receiving a trailer of the given type.
    /// - Parameters:
    ///   - trailerType: The type of trailer to receive.
    ///   - sequenceNumber: The sequence number of the message to peek at.
    /// - Throws: An error if the message could not be peeked at.
    /// - Returns: A peeked preview of the message.
    public func peek(
        trailerType: Mach.Message.Trailer.TrailerType,
        sequenceNumber: inout mach_port_seqno_t
    ) throws -> PeekedMessage {
        var messageSize = mach_msg_size_t(0)
        var messageID = mach_msg_id_t(0)
        let trailer = try Mach.callWithCountInOut(
            arrayType: mach_msg_trailer_info_t.self, dataType: mach_msg_max_trailer_t.self
        ) { trailerInfo, count in
            mach_port_peek(
                self.owningTask.name,
                self.name,
                trailerType.rawValue,
                &sequenceNumber,
                &messageSize,
                &messageID,
                trailerInfo,
                &count
            )
        }
        return PeekedMessage(
            size: messageSize,
            id: messageID,
            trailer: trailer
        )
    }
}
