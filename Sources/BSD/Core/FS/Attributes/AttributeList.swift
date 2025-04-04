import Darwin.POSIX
import Foundation
import System

extension attrlist {
    /// Creates a new attribute list.
    public init(
        commonAttributes: BSD.FSCommonAttributes = [],
        volumeAttributes: BSD.FSVolumeAttributes = [],
        directoryAttributes: BSD.FSDirectoryAttributes = [],
        fileAttributes: BSD.FSFileAttributes = [],
        commonExtendedAttributes: BSD.FSCommonExtendedAttributes = []
    ) {
        self.init(
            bitmapcount: UInt16(ATTR_BIT_MAP_COUNT),
            reserved: UInt16(),
            commonattr: commonAttributes.rawValue,
            volattr: volumeAttributes.rawValue,
            dirattr: directoryAttributes.rawValue,
            fileattr: fileAttributes.rawValue,
            forkattr: commonExtendedAttributes.rawValue
        )
    }

    /// The common attributes in the list.
    public var commonAttributes: BSD.FSCommonAttributes {
        get { BSD.FSCommonAttributes(rawValue: commonattr) }
        set { commonattr = newValue.rawValue }
    }

    /// The volume attributes in the list.
    public var volumeAttributes: BSD.FSVolumeAttributes {
        get { BSD.FSVolumeAttributes(rawValue: volattr) }
        set { volattr = newValue.rawValue }
    }

    /// The directory attributes in the list.
    public var directoryAttributes: BSD.FSDirectoryAttributes {
        get { BSD.FSDirectoryAttributes(rawValue: dirattr) }
        set { dirattr = newValue.rawValue }
    }

    /// The file attributes in the list.
    public var fileAttributes: BSD.FSFileAttributes {
        get { BSD.FSFileAttributes(rawValue: fileattr) }
        set { fileattr = newValue.rawValue }
    }

    /// The extended common attributes in the list.
    public var commonExtendedAttributes: BSD.FSCommonExtendedAttributes {
        get { BSD.FSCommonExtendedAttributes(rawValue: forkattr) }
        set { forkattr = newValue.rawValue }
    }

    /// Gets the attributes for a file or directory.
    @available(macOS 11.0, *)
    public func get(
        for path: FilePath, options: consuming BSD.FSOptions
    ) throws -> BSD.FSAttributeBuffer {
        if !self.commonExtendedAttributes.isEmpty { options.insert(.useExtendedCommonAttributes) }
        // `getattrlist` truncates, so only get the length field first
        let lengthPointer = UnsafeMutablePointer<UInt32>.allocate(capacity: 1)
        let listPointer = UnsafeMutablePointer<attrlist>.allocate(capacity: 1)
        listPointer.pointee = self  // copy the raw list to the pointer for reuse
        try BSD.call(
            getattrlist(
                path.description.cString(using: .utf8),
                UnsafeMutableRawPointer(listPointer),
                lengthPointer,
                MemoryLayout<UInt32>.size,
                options.rawValue
            )
        )
        let buffer = UnsafeMutableRawPointer.allocate(
            byteCount: Int(lengthPointer.pointee), alignment: 4
        )
        // now get the actual attributes
        try BSD.call(
            getattrlist(
                path.description.cString(using: .utf8),
                UnsafeMutableRawPointer(listPointer),
                buffer,
                Int(lengthPointer.pointee),
                options.rawValue
            )
        )
        let secondLength = buffer.withMemoryRebound(
            to: UInt32.self, capacity: 1, { $0.pointee }
        )
        // TODO: determine if there is a nicer way to handle this
        guard secondLength <= lengthPointer.pointee else {
            fatalError("The length of the buffer was greater on the second call.")
        }
        return BSD.FSAttributeBuffer.init(
            UnsafeRawBufferPointer(start: buffer, count: Int(secondLength)),
            from: self
        )
    }
}
