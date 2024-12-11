import Darwin.Mach
import Foundation

/// Adds a string ``Darwin/lockgroup_info/name`` property.
extension lockgroup_info {
    public var name: String {
        withUnsafePointer(to: self.lockgroup_name) {
            pointer in
            return pointer.withMemoryRebound(
                to: CChar.self, capacity: Int(LOCKGROUP_MAX_NAME)
            ) { String(cString: $0) }
        }
    }
}

extension Mach.Host {
    /// Information about the lock groups on the host.
    public var lockGroupInfos: [lockgroup_info] {
        get throws {
            var lockGroupInfoArray: lockgroup_info_array_t?
            var lockGroupCount = mach_msg_type_number_t.max
            try Mach.call(host_lockgroup_info(self.name, &lockGroupInfoArray, &lockGroupCount))
            return (0..<Int(lockGroupCount)).map { index in lockGroupInfoArray![index] }
        }
    }
}
