import MachO

/// A port for a MIG reply.
public final class MIGReplyPort: MachMessagePort {
    public convenience init() {
        self.init(rawPort: mig_get_reply_port(), disposition: .makeSendOnce)
    }
}
