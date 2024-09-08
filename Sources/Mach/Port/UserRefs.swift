import Darwin.Mach
import MachBase

extension Mach.Port {
    func getUserRefs(for right: Right) throws -> Int {
        var refs = mach_port_urefs_t()
        try Mach.Syscall(mach_port_get_refs(self.owningTask.name, self.name, right.rawValue, &refs))
        return Int(refs)
    }
}
