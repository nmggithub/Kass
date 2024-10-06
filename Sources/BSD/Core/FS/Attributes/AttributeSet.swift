import Darwin.POSIX
import Foundation

extension attribute_set_t {
    /// Creates a new attribute set.
    public init(
        commonAttributes: BSD.FSCommonAttributes = [],
        volumeAttributes: BSD.FSVolumeAttributes = [],
        directoryAttributes: BSD.FSDirectoryAttributes = [],
        fileAttributes: BSD.FSFileAttributes = [],
        commonExtendedAttributes: BSD.FSCommonExtendedAttributes = []
    ) {
        self.init(
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
}
