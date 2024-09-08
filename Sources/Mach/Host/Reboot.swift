import Darwin.Mach
import MachBase

extension Mach.Host {
    /// A reboot option.
    public enum RebootOption: Int32 {
        case halt = 0x8
        case upsDelay = 0x100
        case debugger = 0x1000
    }
    /// Reboot the host.
    /// - Parameter option: The reboot options.
    /// - Throws: If the reboot fails.
    public func reboot(_ options: Set<RebootOption> = []) throws {
        try Mach.Syscall(host_reboot(self.name, options.reduce(0) { $0 | $1.rawValue }))
    }
}
