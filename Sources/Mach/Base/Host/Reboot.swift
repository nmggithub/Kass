import CCompat
import Darwin.Mach

extension Mach.Host {
    /// A reboot option.
    public enum RebootOption: Int32 {
        case halt = 0x8
        case upsDelay = 0x100
        case debugger = 0x1000
    }
    /// Reboots the host.
    /// - Parameter options: The reboot options.
    /// - Throws: If the reboot fails.
    public func reboot(_ options: Set<RebootOption> = []) throws {
        try Mach.call(host_reboot(self.name, options.bitmap()))
    }
}