import Darwin.Mach
import Foundation

extension Mach.Task {
    // public struct DYLDImageInfo: RawRepresentable {
    //     public var rawValue: dyld_kernel_image_info
    //     public init(rawValue: dyld_kernel_image_info) {
    //         // self.rawValue = rawValue
    //         self.uuid = UUID(uuid: rawValue.uuid)
    //     }
    //     public let uuid: UUID
    // }
    public struct DYLDImageInfos {
        /// The task.
        public let task: Mach.Task
        public init(in task: Mach.Task) {
            self.task = task
        }
    }
}
