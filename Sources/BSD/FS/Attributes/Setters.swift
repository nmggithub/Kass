import Darwin.POSIX
import System

extension BSD.FS.Attribute.Common {
    /// Sets a common attribute for a file or directory.
    /// - Parameters:
    ///   - value: The value to set the attribute to.
    ///   - path: The path to the file or directory.
    /// - Throws: An error if the attribute cannot be set.
    public func set<DataType: BitwiseCopyable>(to value: consuming DataType, for path: FilePath)
        throws
    {
        let attributeList = BSD.FS.Attribute.List(common: [self])
        let attributeListPointer = UnsafeMutablePointer<attrlist>.allocate(capacity: 1)
        attributeListPointer.pointee = attributeList.rawValue
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
    /// Sets a common attribute for a file or directory.
    /// - Parameters:
    ///   - value: The value to set the attribute to.
    ///   - fileDescriptor: The file descriptor for the file or directory.
    /// - Throws: An error if the attribute cannot be set.
    public func set<DataType: BitwiseCopyable>(
        to value: consuming DataType, for fileDescriptor: consuming FileDescriptor
    ) throws {
        let attributeList = BSD.FS.Attribute.List(common: [self])
        let attributeListPointer = UnsafeMutablePointer<attrlist>.allocate(capacity: 1)
        attributeListPointer.pointee = attributeList.rawValue
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

extension BSD.FS.Attribute.Volume {
    /// Sets a volume attribute for a file or directory.
    /// - Parameters:
    ///   - value: The value to set the attribute to.
    ///   - path: The path to the file or directory.
    /// - Throws: An error if the attribute cannot be set.
    public func set<DataType: BitwiseCopyable>(to value: consuming DataType, for path: FilePath)
        throws
    {
        let attributeList = BSD.FS.Attribute.List(volume: [self])
        let attributeListPointer = UnsafeMutablePointer<attrlist>.allocate(capacity: 1)
        attributeListPointer.pointee = attributeList.rawValue
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
    /// Sets a volume attribute for a file or directory.
    /// - Parameters:
    ///   - value: The value to set the attribute to.
    ///   - fileDescriptor: The file descriptor for the file or directory.
    /// - Throws: An error if the attribute cannot be set.
    public func set<DataType: BitwiseCopyable>(
        to value: consuming DataType, for fileDescriptor: consuming FileDescriptor
    ) throws {
        let attributeList = BSD.FS.Attribute.List(volume: [self])
        let attributeListPointer = UnsafeMutablePointer<attrlist>.allocate(capacity: 1)
        attributeListPointer.pointee = attributeList.rawValue
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

extension BSD.FS.Attribute.Directory {
    /// Sets a directory attribute for a file or directory.
    /// - Parameters:
    ///   - value: The value to set the attribute to.
    ///   - path: The path to the file or directory.
    /// - Throws: An error if the attribute cannot be set.
    public func set<DataType: BitwiseCopyable>(to value: consuming DataType, for path: FilePath)
        throws
    {
        let attributeList = BSD.FS.Attribute.List(directory: [self])
        let attributeListPointer = UnsafeMutablePointer<attrlist>.allocate(capacity: 1)
        attributeListPointer.pointee = attributeList.rawValue
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
    /// Sets a directory attribute for a file or directory.
    /// - Parameters:
    ///   - value: The value to set the attribute to.
    ///   - fileDescriptor: The file descriptor for the file or directory.
    /// - Throws: An error if the attribute cannot be set.
    public func set<DataType: BitwiseCopyable>(
        to value: consuming DataType, for fileDescriptor: consuming FileDescriptor
    ) throws {
        let attributeList = BSD.FS.Attribute.List(directory: [self])
        let attributeListPointer = UnsafeMutablePointer<attrlist>.allocate(capacity: 1)
        attributeListPointer.pointee = attributeList.rawValue
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

extension BSD.FS.Attribute.File {
    /// Sets a file attribute for a file or directory.
    /// - Parameters:
    ///   - value: The value to set the attribute to.
    ///   - path: The path to the file or directory.
    /// - Throws: An error if the attribute cannot be set.
    public func set<DataType: BitwiseCopyable>(to value: consuming DataType, for path: FilePath)
        throws
    {
        let attributeList = BSD.FS.Attribute.List(file: [self])
        let attributeListPointer = UnsafeMutablePointer<attrlist>.allocate(capacity: 1)
        attributeListPointer.pointee = attributeList.rawValue
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
    /// Sets a file attribute for a file or directory.
    /// - Parameters:
    ///   - value: The value to set the attribute to.
    ///   - fileDescriptor: The file descriptor for the file or directory.
    /// - Throws: An error if the attribute cannot be set.
    public func set<DataType: BitwiseCopyable>(
        to value: consuming DataType, for fileDescriptor: consuming FileDescriptor
    ) throws {
        let attributeList = BSD.FS.Attribute.List(file: [self])
        let attributeListPointer = UnsafeMutablePointer<attrlist>.allocate(capacity: 1)
        attributeListPointer.pointee = attributeList.rawValue
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

extension BSD.FS.Attribute.Fork {
    /// Sets a fork attribute for a file or directory.
    /// - Parameters:
    ///   - value: The value to set the attribute to.
    ///   - path: The path to the file or directory.
    /// - Throws: An error if the attribute cannot be set.
    @available(*, deprecated)
    public func set<DataType: BitwiseCopyable>(to value: consuming DataType, for path: FilePath)
        throws
    {
        let attributeList = BSD.FS.Attribute.List(fork: [self])
        let attributeListPointer = UnsafeMutablePointer<attrlist>.allocate(capacity: 1)
        attributeListPointer.pointee = attributeList.rawValue
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
    /// Sets a fork attribute for a file or directory.
    /// - Parameters:
    ///   - value: The value to set the attribute to.
    ///   - fileDescriptor: The file descriptor for the file or directory.
    /// - Throws: An error if the attribute cannot be set.
    @available(*, deprecated)
    public func set<DataType: BitwiseCopyable>(
        to value: consuming DataType, for fileDescriptor: consuming FileDescriptor
    ) throws {
        let attributeList = BSD.FS.Attribute.List(fork: [self])
        let attributeListPointer = UnsafeMutablePointer<attrlist>.allocate(capacity: 1)
        attributeListPointer.pointee = attributeList.rawValue
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

extension BSD.FS.Attribute.Common.Extended {
    /// Sets an extended common attribute for a file or directory.
    /// - Parameters:
    ///   - value: The value to set the attribute to.
    ///   - path: The path to the file or directory.
    /// - Throws: An error if the attribute cannot be set.
    public func set<DataType: BitwiseCopyable>(to value: consuming DataType, for path: FilePath)
        throws
    {
        let attributeList = BSD.FS.Attribute.List(commonExtended: [self])
        let attributeListPointer = UnsafeMutablePointer<attrlist>.allocate(capacity: 1)
        attributeListPointer.pointee = attributeList.rawValue
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
    /// Sets an extended common attribute for a file or directory.
    /// - Parameters:
    ///   - value: The value to set the attribute to.
    ///   - fileDescriptor: The file descriptor for the file or directory.
    /// - Throws: An error if the attribute cannot be set.
    public func set<DataType: BitwiseCopyable>(
        to value: consuming DataType, for fileDescriptor: consuming FileDescriptor
    ) throws {
        let attributeList = BSD.FS.Attribute.List(commonExtended: [self])
        let attributeListPointer = UnsafeMutablePointer<attrlist>.allocate(capacity: 1)
        attributeListPointer.pointee = attributeList.rawValue
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
