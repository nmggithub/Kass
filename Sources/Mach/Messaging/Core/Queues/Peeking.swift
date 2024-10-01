import Darwin.Mach

// These were "functional" C macros in the original code, but Swift doesn't support those.
private func MACH_RCV_TRAILER_ELEMENTS(_ x: Int32) -> Int32 { ((x) & 0xf) << 24 }
private func MACH_RCV_TRAILER_TYPE(_ x: Int32) -> Int32 { ((x) & 0xf) << 28 }

extension Mach {
    /// A peeked preview of a message.
    public struct PeekedMessage {
        /// The advertised size of the message.
        public var size: mach_msg_size_t

        /// The message ID.
        public var id: mach_msg_id_t

        /// The trailer.
        public var trailer: mach_msg_audit_trailer_t
    }
}

extension Mach.MessageServer {
    /// Peeks at the message in the queue with the given sequence number.
    public func peek(sequenceNumber: inout mach_port_seqno_t) throws -> Mach.PeekedMessage {
        var messageSize = mach_msg_size_t(0)
        var messageID = mach_msg_id_t(0)
        let trailer = try Mach.callWithCountInOut(type: mach_msg_audit_trailer_t.self) {
            trailerInfo, count in
            mach_port_peek(
                self.owningTask.name,
                self.name,
                // We peek as much of the trailer as the kernel will let us (which is everything up to, and including, to the audit token).
                mach_msg_trailer_type_t(
                    MACH_RCV_TRAILER_TYPE(MACH_MSG_TRAILER_FORMAT_0)  // This results in 0, so it's not strictly necessary, but this is the documented way to do it.
                        | MACH_RCV_TRAILER_ELEMENTS(MACH_RCV_TRAILER_AUDIT)
                ),
                &sequenceNumber,
                &messageSize,
                &messageID,
                trailerInfo,
                &count
            )
        }
        return Mach.PeekedMessage(
            size: messageSize,
            id: messageID,
            trailer: trailer
        )
    }
}
