import Darwin.Mach

extension Mach {
    public class MIGReplyPort: Mach.Port {
        public convenience init() { self.init(named: mig_get_reply_port()) }
    }
}
