import Darwin.Mach
import Foundation
import KassC.DyldExtra

/// Adds properties to make the `dyld_image_mode` enum more Swift-friendly.
extension dyld_image_mode {
    // While users could (and still can) use these constants directly (since we instruct them
    // to import our helper module), we expose them as static properties as well. This allows
    // users to use them with the dot syntax shorthand (e.g. `.adding`). This is particularly
    // useful when they call our `notify(_:infos:)` method extension (see below).

    public static let adding = dyld_image_adding
    public static let removing = dyld_image_removing
    public static let infoChange = dyld_image_info_change
    public static let dyldMoved = dyld_image_dyld_moved
}

extension Mach.TaskInfoManager {
    /// Information about `dyld` images in the task.
    /// - Warning: All pointers in this structure are valid only in the target task's address space. If the target
    ///     task is not the current task, you should use the virtual memory API to read the data at such pointers.
    public var dyldInfo: dyld_all_image_infos {
        get throws {
            let dyldInfo: task_dyld_info = try self.get(.dyld)
            guard let infoPointer = UnsafeRawPointer(bitPattern: UInt(dyldInfo.all_image_info_addr))
            else { fatalError("`task_info` returned a null pointer for the `dyld` info.") }
            guard MemoryLayout<dyld_all_image_infos>.size >= dyldInfo.all_image_info_size
            else {
                fatalError("The size of the `dyld` info struct doesn't match the expected size.")
            }

            // The pointer is to memory inside the target task's address space, so we need to
            //  use the virtual memory API to ensure that we read the proper data. This might
            //  be overkill if the target task is the current task, but it doesn't hurt to be
            //  safe. The below code will work regardless of the target task, though it won't
            //  change the values of any pointers in the struct itself. The user will have to
            //  use the virtual memory API to read those pointers if they want to use them.
            return try self.task.vm.read(
                from: infoPointer.assumingMemoryBound(to: dyld_all_image_infos.self)
            )
        }
    }
}
