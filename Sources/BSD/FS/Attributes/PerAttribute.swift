import Darwin.POSIX
import Foundation
import System

extension UnsafeMutableRawBufferPointer {
    /// Creates an attribute data buffer from a value.
    /// - Parameter value: The value to create the buffer from.
    /// - Returns: The attribute data buffer.
    fileprivate static func attributeData<DataType: BitwiseCopyable>(from value: inout DataType)
        -> Self
    {
        let buffer = self.init(
            start: UnsafeMutableRawPointer.allocate(
                byteCount: MemoryLayout<DataType>.size,
                alignment: MemoryLayout<DataType>.alignment
            ),
            count: MemoryLayout<DataType>.size
        )
        buffer.baseAddress!.copyMemory(from: &value, byteCount: MemoryLayout<DataType>.size)
        return buffer
    }
    /// Creates an attribute reference data buffer from a value.
    /// - Parameter value: The value to create the buffer from.
    /// - Returns: The attribute reference data buffer.
    fileprivate static func attributeReferenceData(from data: Data) -> Self {
        let buffer = self.init(
            start: UnsafeMutableRawPointer.allocate(
                byteCount: MemoryLayout<attrreference>.size + data.count,
                alignment: 4
            ),
            count: data.count
        )
        var walkingPointer = buffer.baseAddress!
        let rawReferencePointer = walkingPointer.bindMemory(to: attrreference.self, capacity: 1)
        rawReferencePointer.pointee.attr_dataoffset = Int32(MemoryLayout<attrreference>.size)  // the data will be stored directly after the reference
        rawReferencePointer.pointee.attr_length = UInt32(data.count)
        walkingPointer += MemoryLayout<attrreference>.size
        data.withUnsafeBytes { (dataPointer: UnsafeRawBufferPointer) in
            walkingPointer.copyMemory(from: dataPointer.baseAddress!, byteCount: data.count)
        }
        return buffer
    }
}

extension BSD.FS.Attribute {
    /// Any attribute.
    public protocol `Any`: CaseIterable, RawRepresentable where RawValue == UInt32 {}
}

extension BSD.FS.Attribute.Common: BSD.FS.Attribute.`Any` {}
extension BSD.FS.Attribute.Volume: BSD.FS.Attribute.`Any` {}
extension BSD.FS.Attribute.Directory: BSD.FS.Attribute.`Any` {}
extension BSD.FS.Attribute.File: BSD.FS.Attribute.`Any` {}
extension BSD.FS.Attribute.Fork: BSD.FS.Attribute.`Any` {}
extension BSD.FS.Attribute.Common.Extended: BSD.FS.Attribute.`Any` {}

@available(macOS 11.0, *)
extension BSD.FS.Attribute.`Any` {
    /// Creates an attribute list for setting the attribute.
    /// - Parameter options: The options to use when setting the attribute.
    /// - Returns: An attribute list for setting the attribute.
    internal func attributeList(options: Set<BSD.FS.Option>) -> BSD.FS.Attribute.List {
        switch self {
        case let common as BSD.FS.Attribute.Common:
            return BSD.FS.Attribute.List(common: [common], options: options)
        case let volume as BSD.FS.Attribute.Volume:
            return BSD.FS.Attribute.List(volume: [volume], options: options)
        case let directory as BSD.FS.Attribute.Directory:
            return BSD.FS.Attribute.List(directory: [directory], options: options)
        case let file as BSD.FS.Attribute.File:
            return BSD.FS.Attribute.List(file: [file], options: options)
        case let fork as BSD.FS.Attribute.Fork:
            return BSD.FS.Attribute.List(fork: [fork], options: options)
        case let commonExtended as BSD.FS.Attribute.Common.Extended:
            return BSD.FS.Attribute.List(
                commonExtended: [commonExtended],
                options: options.union([.useExtendedCommonAttributes])
            )
        default: fatalError("Unsupported attribute type.")
        }
    }

    /// Gets an attribute for a file or directory.
    /// - Parameters:
    ///   - path: The path to the file or directory.
    ///   - options: The options to use when getting the attribute.
    /// - Throws: An error if the attribute cannot be retrieved.
    /// - Returns: The attribute value, or `nil` if the attribute was not retrieved.
    public func get(
        for path: FilePath, options: Set<BSD.FS.Option> = []
    ) throws -> Any? {
        let attributeList = self.attributeList(options: options)
        let buffer = try attributeList.get(for: path)
        let parsedAttributes = buffer.parse()
        switch self {
        case is BSD.FS.Attribute.Common:
            return parsedAttributes.common[self as! BSD.FS.Attribute.Common]
        case is BSD.FS.Attribute.Volume:
            return parsedAttributes.volume[self as! BSD.FS.Attribute.Volume]
        case is BSD.FS.Attribute.Directory:
            return parsedAttributes.directory[self as! BSD.FS.Attribute.Directory]
        case is BSD.FS.Attribute.File:
            return parsedAttributes.file[self as! BSD.FS.Attribute.File]
        case is BSD.FS.Attribute.Common.Extended:
            return parsedAttributes.commonExtended[self as! BSD.FS.Attribute.Common.Extended]
        default: fatalError("Unsupported attribute type.")
        }
    }

    /// Gets an attribute for a file or directory.
    /// - Parameters:
    ///   - fileDescriptor: The file descriptor for the file or directory.
    ///   - options: The options to use when getting the attribute.
    /// - Throws: An error if the attribute cannot be retrieved.
    /// - Returns: The attribute value, or `nil` if the attribute was not retrieved.
    public func get(
        for fileDescriptor: FileDescriptor, options: Set<BSD.FS.Option> = []
    ) throws -> Any? {
        let attributeList = self.attributeList(options: options)
        let buffer = try attributeList.get(for: fileDescriptor)
        let parsedAttributes = buffer.parse()
        switch self {
        case is BSD.FS.Attribute.Common:
            return parsedAttributes.common[self as! BSD.FS.Attribute.Common]
        case is BSD.FS.Attribute.Volume:
            return parsedAttributes.volume[self as! BSD.FS.Attribute.Volume]
        case is BSD.FS.Attribute.Directory:
            return parsedAttributes.directory[self as! BSD.FS.Attribute.Directory]
        case is BSD.FS.Attribute.File:
            return parsedAttributes.file[self as! BSD.FS.Attribute.File]
        case is BSD.FS.Attribute.Common.Extended:
            return parsedAttributes.commonExtended[self as! BSD.FS.Attribute.Common.Extended]
        default: fatalError("Unsupported attribute type.")
        }
    }

    /// Sets an attribute for a file or directory.
    /// - Parameters:
    ///   - buffer: The buffer containing the attribute data.
    ///   - path: The path to the file or directory.
    ///   - options: The options to use when setting the attribute.
    /// - Throws: An error if the attribute cannot be set.
    public func set(
        to buffer: UnsafeMutableRawBufferPointer, for path: FilePath,
        options: Set<BSD.FS.Option> = []
    ) throws {
        let attributeList = self.attributeList(options: options)
        let attributeListPointer = UnsafeMutablePointer<attrlist>.allocate(capacity: 1)
        attributeListPointer.pointee = attributeList.rawValue
        defer { attributeListPointer.deallocate() }
        try BSD.syscall(
            setattrlist(
                path.description.cString(using: .utf8),
                attributeListPointer,
                buffer.baseAddress!,
                buffer.count,
                attributeList.options.bitmap()
            )
        )
    }
    /// Sets an attribute for a file or directory.
    /// - Parameters:
    ///   - buffer: The buffer containing the attribute data.
    ///   - fileDescriptor: The file descriptor for the file or directory.
    /// - Throws: An error if the attribute cannot be set.
    public func set(
        to buffer: UnsafeMutableRawBufferPointer, for fileDescriptor: FileDescriptor,
        options: Set<BSD.FS.Option> = []
    ) throws {
        let attributeList = self.attributeList(options: options)
        let attributeListPointer = UnsafeMutablePointer<attrlist>.allocate(capacity: 1)
        attributeListPointer.pointee = attributeList.rawValue
        defer { attributeListPointer.deallocate() }
        try BSD.syscall(
            fsetattrlist(
                fileDescriptor.rawValue,
                attributeListPointer,
                buffer.baseAddress!,
                buffer.count,
                attributeList.options.bitmap()
            )
        )
    }

    /// Sets an attribute for a file or directory.
    /// - Parameters:
    ///   - value: The value to set the attribute to.
    ///   - path: The path to the file or directory.
    ///   - options: The options to use when setting the attribute.
    /// - Throws: An error if the attribute cannot be set.
    public func set<DataType: BitwiseCopyable>(
        to value: consuming DataType, for path: FilePath,
        options: Set<BSD.FS.Option> = []
    ) throws {
        let buffer = UnsafeMutableRawBufferPointer.attributeData(from: &value)
        defer { buffer.deallocate() }
        try self.set(to: buffer, for: path, options: options)
    }
    /// Sets an attribute for a file or directory.
    /// - Parameters:
    ///   - value: The value to set the attribute to.
    ///   - fileDescriptor: The file descriptor for the file or directory.
    /// - Throws: An error if the attribute cannot be set.
    public func set<DataType: BitwiseCopyable>(
        to value: consuming DataType, for fileDescriptor: FileDescriptor,
        options: Set<BSD.FS.Option> = []
    ) throws {
        let buffer = UnsafeMutableRawBufferPointer.attributeData(from: &value)
        defer { buffer.deallocate() }
        try self.set(to: buffer, for: fileDescriptor, options: options)
    }

    /// Sets an attribute for a file or directory using a reference.
    /// - Parameters:
    ///   - data: The data to set the attribute reference to.
    ///   - path: The path to the file or directory.
    ///   - options: The options to use when setting the attribute.
    /// - Throws: An error if the attribute cannot be set.
    public func setReference(
        to data: Data, for path: FilePath,
        options: Set<BSD.FS.Option> = []
    ) throws {
        let buffer = UnsafeMutableRawBufferPointer.attributeReferenceData(from: data)
        defer { buffer.deallocate() }
        try self.set(to: buffer, for: path, options: options)
    }

    /// Sets an attribute for a file or directory using a reference.
    /// - Parameters:
    ///   - data: The data to set the attribute reference to.
    ///   - fileDescriptor: The file descriptor for the file or directory.
    ///   - options: The options to use when setting the attribute.
    /// - Throws: An error if the attribute cannot be set.
    public func setReference(
        to data: Data, for fileDescriptor: FileDescriptor,
        options: Set<BSD.FS.Option> = []
    ) throws {
        let buffer = UnsafeMutableRawBufferPointer.attributeReferenceData(from: data)
        defer { buffer.deallocate() }
        try self.set(to: buffer, for: fileDescriptor, options: options)
    }

    /// Sets an attribute for a file or directory using a reference.
    /// - Parameters:
    ///   - value: The value to set the attribute reference to.
    ///   - path: The path to the file or directory.
    ///   - options: The options to use when setting the attribute.
    /// - Throws: An error if the attribute cannot be set.
    public func setReference<DataType: BitwiseCopyable>(
        to value: DataType, for path: FilePath,
        options: Set<BSD.FS.Option> = []
    ) throws {
        let data = withUnsafeBytes(of: value) { valueBuffer in Data(valueBuffer) }
        try self.setReference(to: data, for: path, options: options)
    }

    /// Sets an attribute for a file or directory using a reference.
    /// - Parameters:
    ///   - value: The value to set the attribute reference to.
    ///   - fileDescriptor: The file descriptor for the file or directory.
    ///   - options: The options to use when setting the attribute.
    /// - Throws: An error if the attribute cannot be set.
    public func setReference<DataType: BitwiseCopyable>(
        to value: DataType, for fileDescriptor: FileDescriptor,
        options: Set<BSD.FS.Option> = []
    ) throws {
        let data = withUnsafeBytes(of: value) { valueBuffer in Data(valueBuffer) }
        try self.setReference(to: data, for: fileDescriptor, options: options)
    }

}
