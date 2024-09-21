import Darwin.POSIX
import Foundation
import System

extension BSD.FS.Attribute {
    /// An attribute list.
    public struct List: RawRepresentable {
        public var rawValue: attrlist {
            attrlist(
                bitmapcount: UInt16(ATTR_BIT_MAP_COUNT),
                reserved: UInt16(),
                commonattr: common.bitmap(),
                // ATTR_VOL_INFO is not a real attribute, but a flag to indicate that volume attributes are requested
                volattr: volume.count > 0 ? volume.bitmap() | ATTR_VOL_INFO : 0,
                dirattr: directory.bitmap(),
                fileattr: file.bitmap(),
                forkattr: options.contains(.useExtendedCommonAttributes)
                    ? commonExtended.bitmap()
                    : fork.bitmap()
            )
        }
        public init(rawValue: attrlist) {
            self.common = Common.set(from: rawValue.commonattr)
            self.volume = Volume.set(from: rawValue.volattr)
            self.directory = Directory.set(from: rawValue.dirattr)
            self.file = File.set(from: rawValue.fileattr)
            if Fork.set(from: rawValue.forkattr).isEmpty {
                self.commonExtended = Common.Extended.set(from: rawValue.forkattr)
                self.fork = []
            } else {
                self.fork = Fork.set(from: rawValue.forkattr)
                self.commonExtended = []
            }
            self.options = self.commonExtended.isEmpty ? [] : [.useExtendedCommonAttributes]
        }
        public init(
            common: Swift.Set<Common> = [],
            volume: Swift.Set<Volume> = [],
            directory: Swift.Set<Directory> = [],
            file: Swift.Set<File> = [],
            fork: Swift.Set<Fork> = [],
            commonExtended: Swift.Set<Common.Extended> = [],
            options: Swift.Set<BSD.FS.Option> = []
        ) {
            self.common = common
            self.volume = volume
            self.directory = directory
            self.file = file
            self.fork = fork
            self.commonExtended = commonExtended
            self.options = options
        }
        public var common: Swift.Set<Common>
        public var volume: Swift.Set<Volume>
        public var directory: Swift.Set<Directory>
        public var file: Swift.Set<File>
        @available(*, deprecated)
        public var fork: Swift.Set<Fork>
        public var commonExtended: Swift.Set<Common.Extended>
        /// - Important: ``BSD/FS/Option`` is used for other system calls. Not all options
        /// are valid for use with attributes lists.
        public var options: Swift.Set<BSD.FS.Option>

        /// Gets the attributes for a file or directory.
        /// - Parameter path: The path to the file or directory.
        /// - Throws: An error if the operation fails.
        /// - Important: This function makes an initial syscall to get the buffer size. Errors from both syscalls are thrown.
        /// - Warning: This function will crash if the length of the buffer is greater on the second call.
        public func get(for path: FilePath) throws -> BSD.FS.Attribute.Buffer {
            // `getattrlist` truncates, so only get the length field first
            let lengthPointer = UnsafeMutablePointer<UInt32>.allocate(capacity: 1)
            let listPointer = UnsafeMutablePointer<attrlist>.allocate(capacity: 1)
            listPointer.pointee = rawValue  // copy the raw list to the pointer for reuse
            try BSD.syscall(
                getattrlist(
                    path.description.cString(using: .utf8),
                    UnsafeMutableRawPointer(listPointer),
                    lengthPointer,
                    MemoryLayout<UInt32>.size,
                    self.options.bitmap()
                )
            )
            let buffer = UnsafeMutableRawPointer.allocate(
                byteCount: Int(lengthPointer.pointee), alignment: 4
            )
            // now get the actual attributes
            try BSD.syscall(
                getattrlist(
                    path.description.cString(using: .utf8),
                    UnsafeMutableRawPointer(listPointer),
                    buffer,
                    Int(lengthPointer.pointee),
                    self.options.bitmap()
                )
            )
            let secondLength = buffer.withMemoryRebound(
                to: UInt32.self, capacity: 1, { $0.pointee }
            )
            // TODO: determine if there is a nicer way to handle this
            guard secondLength <= lengthPointer.pointee else {
                fatalError("The length of the buffer was greater on the second call.")
            }
            return BSD.FS.Attribute.Buffer.init(
                UnsafeRawBufferPointer(start: buffer, count: Int(secondLength)),
                from: self
            )
        }

        /// Gets the attributes for a file or directory.
        /// - Parameter fileDescriptor: The file descriptor for the file or directory.
        /// - Throws: An error if the operation fails.
        /// - Important: This function makes an initial syscall to get the buffer size. Errors from both syscalls are thrown.
        /// - Warning: This function will crash if the length of the buffer is greater on the second call.
        public func get(for fileDescriptor: FileDescriptor) throws -> BSD.FS.Attribute.Buffer {
            // `fgetattrlist` truncates, so only get the length field first
            let lengthPointer = UnsafeMutablePointer<UInt32>.allocate(capacity: 1)
            let listPointer = UnsafeMutablePointer<attrlist>.allocate(capacity: 1)
            listPointer.pointee = rawValue  // copy the raw list to the pointer for reuse
            try BSD.syscall(
                fgetattrlist(
                    fileDescriptor.rawValue,
                    UnsafeMutableRawPointer(listPointer),
                    lengthPointer,
                    MemoryLayout<UInt32>.size,
                    self.options.bitmap()
                )
            )
            let buffer = UnsafeMutableRawPointer.allocate(
                byteCount: Int(lengthPointer.pointee), alignment: 4
            )
            // now get the actual attributes
            try BSD.syscall(
                fgetattrlist(
                    fileDescriptor.rawValue,
                    UnsafeMutableRawPointer(listPointer),
                    buffer,
                    Int(lengthPointer.pointee),
                    self.options.bitmap()
                )
            )
            let secondLength = buffer.withMemoryRebound(
                to: UInt32.self, capacity: 1, { $0.pointee }
            )
            // TODO: determine if there is a nicer way to handle this
            guard secondLength <= lengthPointer.pointee else {
                fatalError("The length of the buffer was greater on the second call.")
            }
            return BSD.FS.Attribute.Buffer.init(
                UnsafeRawBufferPointer(start: buffer, count: Int(secondLength)),
                from: self
            )
        }
    }

}
