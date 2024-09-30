import Darwin.Mach
import Foundation
import MachC.DyldExtra

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

/// Adds properties to make the `dyld_image_info` struct more Swift-friendly.
extension dyld_image_info {
    public var imageFilePathString: String { String(cString: self.imageFilePath) }
}

/// Adds properties to make the `dyld_aot_image_info` struct more Swift-friendly.
extension dyld_aot_image_info {
    public var aotImageKeyData: Data {
        withUnsafeBytes(of: self.aotImageKey) { bytes in Data(bytes) }
    }
}

/// Adds a failible initializer to convert a potentially-nil C string to a Swift string.
extension String {
    internal init?(cString: UnsafePointer<CChar>?) {
        guard let actualCString = cString else { return nil }
        self.init(cString: actualCString)
    }
}

/// Adds a failible initializer to convert a potentially-nil data pointer to a Swift `Data` object.
extension Data {
    internal init?(bytes: UnsafeRawPointer?, count: Int) {
        guard let actualBytes = bytes else { return nil }
        self.init(bytes: actualBytes, count: count)
    }
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
    public var dyldVersionString: String? { String(cString: self.dyldVersion) }
    @available(macOS, introduced: 10.6)
    public var errorMessageString: String? { String(cString: self.errorMessage) }
    @available(macOS, introduced: 10.6)
    public var uuids: [dyld_uuid_info] {
        guard let uuidArray = self.uuidArray else { return [] }
        return (0..<Int(self.uuidArrayCount)).map { index in uuidArray[index] }
    }
    @available(macOS, introduced: 10.13)
    public var compactDyldImageInfo: Data? {
        Data(
            bytes: UnsafeRawPointer(bitPattern: self.compact_dyld_image_info_addr),
            count: Int(self.compact_dyld_image_info_size)
        )
    }

}

extension Mach.TaskInfoManager {
    /// Information about `dyld` images in the task.
    public var dyldInfo: dyld_all_image_infos {
        get throws {
            let dyldInfo: task_dyld_info = try self.get(.dyld)
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
