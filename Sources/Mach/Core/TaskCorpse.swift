import Darwin.Mach
import Foundation

extension Mach.Task {
    /// A corpse task.
    public class Corpse: Mach.Task {
        /// Information about the corpse.
        public var corpseInfo: Data {
            get throws {
                var address = mach_vm_address_t()
                var size = mach_vm_size_t()
                try Mach.call(
                    task_map_corpse_info_64(self.owningTask.name, self.name, &address, &size)
                )
                guard let addressPointer = UnsafeRawPointer(bitPattern: Int(address)) else {
                    fatalError("`task_map_corpse_info_64` returned a null pointer.")
                }
                return Data(
                    bytes: addressPointer,
                    count: Int(size)
                )
            }
        }
    }

    /// Generates a corpse for the task.
    public func generateCorpse() throws -> Corpse {
        var corpseName: task_name_t = TASK_NAME_NULL
        try Mach.call(task_generate_corpse(self.name, &corpseName))
        return Corpse(named: corpseName)
    }
}
