import Darwin.Mach
import MachBase
import MachPort

extension Mach {
    /// A host (port).
    public class Host: Mach.Port {
        /// The current host.
        public static var current: Self { Self(named: mach_host_self()) }
        /// The boot info for the host.
        public var bootInfo: String {
            get throws {
                let bootInfoStr = UnsafeMutablePointer<CChar>.allocate(
                    capacity: Int(KERNEL_BOOT_INFO_MAX)
                )
                try Mach.Syscall(host_get_boot_info(self.name, bootInfoStr))
                return String(cString: bootInfoStr)
            }
        }
    }
}
