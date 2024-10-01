import Darwin.Mach

extension Mach {
    /// A reply port for a MIG request.
    public class MIGReplyPort: Mach.Port {
        public convenience init() { self.init(named: mig_get_reply_port()) }
    }
}
