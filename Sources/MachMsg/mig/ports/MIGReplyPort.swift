import MachO

/// A port for a MIG reply.
final class MIGReplyPort: MachMessagePort {
    convenience init() {
        self.init(rawPort: mig_get_reply_port(), disposition: .makeSendOnce)
    }
}
