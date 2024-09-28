import Darwin.Mach
import Foundation
import MachC.DyldExtra

/// Adds properties to make the `dyld_aot_image_info` struct more Swift-friendly.
extension dyld_aot_image_info {
    public var aotImageKeyData: Data { withUnsafeBytes(of: self.aotImageKey) { Data($0) } }
}

/// Adds properties to make the `dyld_all_image_infos` struct more Swift-friendly.
extension dyld_all_image_infos {  // Note: The availability constraints are based on comments in the original header file.
    public var infos: [dyld_image_info] {
        guard let infoArray = self.infoArray else { return [] }
        return (0..<Int(self.infoArrayCount)).map { index in infoArray[index] }
    }
    public func notify(_ mode: dyld_image_mode, _ infos: consuming [dyld_image_info]) {
        self.notification(mode, UInt32(infos.count), infos)
    }
    @available(macOS, introduced: 10.6)
    public var dyldVersionString: String { String(cString: self.dyldVersion) }
    @available(macOS, introduced: 10.6)
    public var errorMessageString: String { String(cString: self.errorMessage) }
    @available(macOS, introduced: 10.6)
    public var uuids: [dyld_uuid_info] {
        guard let uuidArray = self.uuidArray else { return [] }
        return (0..<Int(self.uuidArrayCount)).map { index in uuidArray[index] }
    }
    @available(macOS, introduced: 10.13)
    public var compactDyldImageInfo: Data? {
        guard let addr = UnsafeRawPointer(bitPattern: self.compact_dyld_image_info_addr) else {
            return nil
        }
        return Data(
            bytes: addr,
            count: Int(self.compact_dyld_image_info_size)
        )
    }

}

extension Mach.Task {
    /// Information about `dyld` images in the task.
    public var dyldInfo: dyld_all_image_infos {
        get throws {
            let dyldInfo: task_dyld_info = try self.getInfo(.dyld)
            guard let infoPointer = UnsafeRawPointer(bitPattern: UInt(dyldInfo.all_image_info_addr))
            else { fatalError("`task_info` returned a null pointer for the `dyld` info.") }
            guard MemoryLayout<dyld_all_image_infos>.size >= dyldInfo.all_image_info_size
            else {
                fatalError("The size of the `dyld` info struct doesn't match the expected size.")
            }
            return infoPointer.load(as: dyld_all_image_infos.self)
        }
    }
}
