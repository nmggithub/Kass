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
                volattr: volume.bitmap(),
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
            options.contains(.useExtendedCommonAttributes)
                ? (self.commonExtended = Common.Extended.set(from: rawValue.forkattr))
                : (self.fork = Fork.set(from: rawValue.forkattr))
        }
        public init() {}
        public var common: Set<Common> = []
        public var volume: Set<Volume> = []
        public var directory: Set<Directory> = []
        public var file: Set<File> = []
        @available(*, deprecated)
        public var fork: Set<Fork> = []
        public var commonExtended: Set<Common.Extended> = []
        /// - Important: ``BSD/FS/Option`` is used for other system calls. Not all options
        /// are valid for use with attributes lists.
        public var options: Set<BSD.FS.Option> = []

        /// Gets the attributes for a file or directory.
        /// - Parameter path: The path to the file or directory.
        /// - Throws: An error if the operation fails.
        /// - Important: The underlying system call is called twice. The first call gets the length of
        /// the attributes list, while the second gets the actual attribute list. Both calls can fail,
        /// and errors from both calls are thrown from this function without any additional handling.
        /// - Warning: This function will crash if the length of the attribute list is greater on the second call.
        public func get(of path: FilePath) throws -> Data {
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
                fatalError("The length of the attribute list changed between calls.")
            }
            // TODO: Return actual attributes instead of raw data
            return Data(bytes: buffer, count: Int(lengthPointer.pointee))
        }
    }
}
