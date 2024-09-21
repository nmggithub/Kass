import Darwin.POSIX
import System

extension BSD.FS.Attribute.`Any` {
    internal var attributeList: BSD.FS.Attribute.List {
        switch self {
        case let common as BSD.FS.Attribute.Common:
            return BSD.FS.Attribute.List(common: [common])
        case let volume as BSD.FS.Attribute.Volume:
            return BSD.FS.Attribute.List(volume: [volume])
        case let directory as BSD.FS.Attribute.Directory:
            return BSD.FS.Attribute.List(directory: [directory])
        case let file as BSD.FS.Attribute.File:
            return BSD.FS.Attribute.List(file: [file])
        case let fork as BSD.FS.Attribute.Fork:
            return BSD.FS.Attribute.List(fork: [fork])
        case let commonExtended as BSD.FS.Attribute.Common.Extended:
            return BSD.FS.Attribute.List(commonExtended: [commonExtended])
        default: fatalError("Unsupported attribute type.")
        }
    }

    /// Sets a common attribute for a file or directory.
    /// - Parameters:
    ///   - value: The value to set the attribute to.
    ///   - path: The path to the file or directory.
    /// - Throws: An error if the attribute cannot be set.
    public func set<DataType: BitwiseCopyable>(to value: consuming DataType, for path: FilePath)
        throws
    {
        let attributeListPointer = UnsafeMutablePointer<attrlist>.allocate(capacity: 1)
        attributeListPointer.pointee = self.attributeList.rawValue
        defer { attributeListPointer.deallocate() }
        try BSD.syscall(
            setattrlist(
                path.description.cString(using: .utf8),
                attributeListPointer,
                &value,
                MemoryLayout<DataType>.size,
                attributeList.options.bitmap()
            )
        )
    }
    /// Sets an attribute for a file or directory.
    /// - Parameters:
    ///   - value: The value to set the attribute to.
    ///   - fileDescriptor: The file descriptor for the file or directory.
    /// - Throws: An error if the attribute cannot be set.
    public func set<DataType: BitwiseCopyable>(
        to value: consuming DataType, for fileDescriptor: consuming FileDescriptor
    ) throws {
        let attributeListPointer = UnsafeMutablePointer<attrlist>.allocate(capacity: 1)
        attributeListPointer.pointee = self.attributeList.rawValue
        defer { attributeListPointer.deallocate() }
        try BSD.syscall(
            fsetattrlist(
                fileDescriptor.rawValue,
                attributeListPointer,
                &value,
                MemoryLayout<DataType>.size,
                attributeList.options.bitmap()
            )
        )
    }
}
