// import Darwin.POSIX
// import Foundation
// import System

// extension UnsafeMutableRawBufferPointer {
//     /// Creates an attribute data buffer from a value.
//     /// - Parameter value: The value to create the buffer from.
//     /// - Returns: The attribute data buffer.
//     fileprivate static func attributeData<DataType: BitwiseCopyable>(from value: inout DataType)
//         -> Self
//     {
//         let buffer = self.init(
//             start: UnsafeMutableRawPointer.allocate(
//                 byteCount: MemoryLayout<DataType>.size,
//                 alignment: MemoryLayout<DataType>.alignment
//             ),
//             count: MemoryLayout<DataType>.size
//         )
//         buffer.baseAddress!.copyMemory(from: &value, byteCount: MemoryLayout<DataType>.size)
//         return buffer
//     }
//     /// Creates an attribute reference data buffer from a value.
//     /// - Parameter value: The value to create the buffer from.
//     /// - Returns: The attribute reference data buffer.
//     fileprivate static func attributeReferenceData(from data: Data) -> Self {
//         let buffer = self.init(
//             start: UnsafeMutableRawPointer.allocate(
//                 byteCount: MemoryLayout<attrreference>.size + data.count,
//                 alignment: 4
//             ),
//             count: data.count
//         )
//         var walkingPointer = buffer.baseAddress!
//         let rawReferencePointer = walkingPointer.bindMemory(to: attrreference.self, capacity: 1)
//         rawReferencePointer.pointee.attr_dataoffset = Int32(MemoryLayout<attrreference>.size)  // the data will be stored directly after the reference
//         rawReferencePointer.pointee.attr_length = UInt32(data.count)
//         walkingPointer += MemoryLayout<attrreference>.size
//         data.withUnsafeBytes { (dataPointer: UnsafeRawBufferPointer) in
//             walkingPointer.copyMemory(from: dataPointer.baseAddress!, byteCount: data.count)
//         }
//         return buffer
//     }
// }
// @available(macOS 11.0, *)
// extension BSD.FSAttributes {
//     /// Creates an attribute list for setting the attributes.
//     internal func attributeList() -> attrlist {
//         switch self {
//         case let common as BSD.FSCommonAttributes:
//             return attrlist(commonAttributes: common)
//         case let volume as BSD.FSVolumeAttributes:
//             return attrlist(volumeAttributes: volume)
//         case let directory as BSD.FSDirectoryAttributes:
//             return attrlist(directoryAttributes: directory)
//         case let file as BSD.FSFileAttributes:
//             return attrlist(fileAttributes: file)
//         case let commonExtended as BSD.FSCommonExtendedAttributes:
//             return attrlist(commonExtendedAttributes: commonExtended)
//         default: fatalError("Unsupported attribute type.")
//         }
//     }

//     /// Gets attributes for a file or directory.
//     public func get(
//         for path: FilePath, options: BSD.FSOptions = []
//     ) throws -> [(any BSD.FSAttributes): Any] {
//         let attributeList = self.attributeList()
//         let buffer = try attributeList.get(for: path, options: options)
//         let parsedAttributes = buffer.parse()
//         return switch self {
//         case is BSD.FSCommonAttributes: parsedAttributes.common
//         case is BSD.FSVolumeAttributes: parsedAttributes.volume
//         case is BSD.FSDirectoryAttributes: parsedAttributes.directory
//         case is BSD.FSFileAttributes: parsedAttributes.file
//         case is BSD.FSCommonExtendedAttributes: parsedAttributes.commonExtended
//         default: fatalError("Unsupported attribute type.")
//         }
//     }

//     /// Sets an attribute for a file or directory.
//     /// - Parameters:
//     ///   - buffer: The buffer containing the attribute data.
//     ///   - path: The path to the file or directory.
//     ///   - options: The options to use when setting the attribute.
//     /// - Throws: An error if the attribute cannot be set.
//     public func set(
//         to buffer: UnsafeMutableRawBufferPointer, for path: FilePath,
//         options: Set<BSD.FS.Option> = []
//     ) throws {
//         let attributeList = self.attributeList(options: options)
//         let attributeListPointer = UnsafeMutablePointer<attrlist>.allocate(capacity: 1)
//         attributeListPointer.pointee = attributeList.rawValue
//         defer { attributeListPointer.deallocate() }
//         try BSD.syscall(
//             setattrlist(
//                 path.description.cString(using: .utf8),
//                 attributeListPointer,
//                 buffer.baseAddress!,
//                 buffer.count,
//                 attributeList.options.bitmap()
//             )
//         )
//     }
//     /// Sets an attribute for a file or directory.
//     /// - Parameters:
//     ///   - buffer: The buffer containing the attribute data.
//     ///   - fileDescriptor: The file descriptor for the file or directory.
//     /// - Throws: An error if the attribute cannot be set.
//     public func set(
//         to buffer: UnsafeMutableRawBufferPointer, for fileDescriptor: FileDescriptor,
//         options: Set<BSD.FS.Option> = []
//     ) throws {
//         let attributeList = self.attributeList(options: options)
//         let attributeListPointer = UnsafeMutablePointer<attrlist>.allocate(capacity: 1)
//         attributeListPointer.pointee = attributeList.rawValue
//         defer { attributeListPointer.deallocate() }
//         try BSD.syscall(
//             fsetattrlist(
//                 fileDescriptor.rawValue,
//                 attributeListPointer,
//                 buffer.baseAddress!,
//                 buffer.count,
//                 attributeList.options.bitmap()
//             )
//         )
//     }

//     /// Sets an attribute for a file or directory.
//     /// - Parameters:
//     ///   - value: The value to set the attribute to.
//     ///   - path: The path to the file or directory.
//     ///   - options: The options to use when setting the attribute.
//     /// - Throws: An error if the attribute cannot be set.
//     public func set<DataType: BitwiseCopyable>(
//         to value: consuming DataType, for path: FilePath,
//         options: Set<BSD.FS.Option> = []
//     ) throws {
//         let buffer = UnsafeMutableRawBufferPointer.attributeData(from: &value)
//         defer { buffer.deallocate() }
//         try self.set(to: buffer, for: path, options: options)
//     }
//     /// Sets an attribute for a file or directory.
//     /// - Parameters:
//     ///   - value: The value to set the attribute to.
//     ///   - fileDescriptor: The file descriptor for the file or directory.
//     /// - Throws: An error if the attribute cannot be set.
//     public func set<DataType: BitwiseCopyable>(
//         to value: consuming DataType, for fileDescriptor: FileDescriptor,
//         options: Set<BSD.FS.Option> = []
//     ) throws {
//         let buffer = UnsafeMutableRawBufferPointer.attributeData(from: &value)
//         defer { buffer.deallocate() }
//         try self.set(to: buffer, for: fileDescriptor, options: options)
//     }

//     /// Sets an attribute for a file or directory using a reference.
//     /// - Parameters:
//     ///   - data: The data to set the attribute reference to.
//     ///   - path: The path to the file or directory.
//     ///   - options: The options to use when setting the attribute.
//     /// - Throws: An error if the attribute cannot be set.
//     public func setReference(
//         to data: Data, for path: FilePath,
//         options: Set<BSD.FS.Option> = []
//     ) throws {
//         let buffer = UnsafeMutableRawBufferPointer.attributeReferenceData(from: data)
//         defer { buffer.deallocate() }
//         try self.set(to: buffer, for: path, options: options)
//     }

//     /// Sets an attribute for a file or directory using a reference.
//     /// - Parameters:
//     ///   - data: The data to set the attribute reference to.
//     ///   - fileDescriptor: The file descriptor for the file or directory.
//     ///   - options: The options to use when setting the attribute.
//     /// - Throws: An error if the attribute cannot be set.
//     public func setReference(
//         to data: Data, for fileDescriptor: FileDescriptor,
//         options: Set<BSD.FS.Option> = []
//     ) throws {
//         let buffer = UnsafeMutableRawBufferPointer.attributeReferenceData(from: data)
//         defer { buffer.deallocate() }
//         try self.set(to: buffer, for: fileDescriptor, options: options)
//     }

//     /// Sets an attribute for a file or directory using a reference.
//     /// - Parameters:
//     ///   - value: The value to set the attribute reference to.
//     ///   - path: The path to the file or directory.
//     ///   - options: The options to use when setting the attribute.
//     /// - Throws: An error if the attribute cannot be set.
//     public func setReference<DataType: BitwiseCopyable>(
//         to value: DataType, for path: FilePath,
//         options: Set<BSD.FS.Option> = []
//     ) throws {
//         let data = withUnsafeBytes(of: value) { valueBuffer in Data(valueBuffer) }
//         try self.setReference(to: data, for: path, options: options)
//     }

//     /// Sets an attribute for a file or directory using a reference.
//     /// - Parameters:
//     ///   - value: The value to set the attribute reference to.
//     ///   - fileDescriptor: The file descriptor for the file or directory.
//     ///   - options: The options to use when setting the attribute.
//     /// - Throws: An error if the attribute cannot be set.
//     public func setReference<DataType: BitwiseCopyable>(
//         to value: DataType, for fileDescriptor: FileDescriptor,
//         options: Set<BSD.FS.Option> = []
//     ) throws {
//         let data = withUnsafeBytes(of: value) { valueBuffer in Data(valueBuffer) }
//         try self.setReference(to: data, for: fileDescriptor, options: options)
//     }

// }
