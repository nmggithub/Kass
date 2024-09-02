import MachO

/// A Mach Interface Generator (MIG) reply message.
open class MIGReply<Payload: MIGPayload>: MachMessage<Payload> {
    public required init(rawValue: UnsafeMutablePointer<mach_msg_header_t>) {
        super.init(rawValue: rawValue)
    }
}
