import Darwin.Mach
import MachPort

extension Mach.Message.MIG {
    public class ReplyPort: Mach.Port {
        public convenience init() {
            self.init(named: mig_get_reply_port())
        }
    }
}
