import CCompat  // for bitmap functions
import Darwin.POSIX
import Foundation
import System

extension BSD.FS {
    public enum Option: UInt32 {
        /// Do not follow symbolic links.
        case noFollow = 0x0000_0001
        case noInMemoryUpdate = 0x0000_0002
        case reportFullSize = 0x0000_0004
        case returnInvalidAttributes = 0x0000_0008
        case exchangeDataOnly = 0x0000_0010
        case useExtendedCommonAttributes = 0x0000_0020
        case listSnapshot = 0x0000_0040
        case noFirmlinkPath = 0x0000_0080
        case followFirmlink = 0x0000_0100
        case returnRealDevice = 0x0000_0200
        case utimesNull = 0x0000_0400
        /// - Note: This option is the same as ``noFollow``, but with the addition that
        /// an error is returned if a symbolic link is encountered.
        case noFollowWithError = 0x0000_0800
    }
    /// The attribute namespace.
    public struct Attribute: Namespace {

        // IMPORTANT: The declaration order of these enums is important. They must be in the same order as the ones in the
        // `getattrlist` manpage. We use this order to ensure we parse the returned attributes in the correct order.

        /// A common attribute.
        public enum Common: UInt32, CaseIterable {
            case returnedAttributes = 0x8000_0000
            case name = 0x0000_0001
            case deviceID = 0x0000_0002
            case filesystemID = 0x0000_0004
            case objectType = 0x0000_0008
            case objectTag = 0x0000_0010
            case objectID = 0x0000_0020
            case objectPermanentID = 0x0000_0040
            case parentObjectID = 0x0000_0080
            case textEncoding = 0x0000_0100
            case creationTime = 0x0000_0200
            case modificationTime = 0x0000_0400
            case changeTime = 0x0000_0800
            case accessTime = 0x0000_1000
            case backupTime = 0x0000_2000
            case finderInfo = 0x0000_4000
            case ownerID = 0x0000_8000
            case groupID = 0x0001_0000
            case accessMask = 0x0002_0000
            case flags = 0x0004_0000
            case generationCount = 0x0008_0000
            case documentID = 0x0010_0000
            /// An extended common attribute.
            case userAccess = 0x0020_0000
            case extendedSecurity = 0x0040_0000
            case ownerUUID = 0x0080_0000
            case groupUUID = 0x0100_0000
            case fileID = 0x0200_0000
            case parentID = 0x0400_0000
            case fullPath = 0x0800_0000
            case addedTime = 0x1000_0000
            case dataProtectionClass = 0x2000_0000
            public enum Extended: UInt32, CaseIterable {
                case relativePath = 0x0000_0004
                case privateSize = 0x0000_0008
                case linkID = 0x0000_0010
                case pathWithNoFirmlinks = 0x0000_0020
                case realDeviceID = 0x0000_0040
                case realFilesystemID = 0x0000_0080
                case cloneID = 0x0000_0100
                case extraFlags = 0x0000_0200
                case recursiveGenerationCount = 0x0000_0400
                case attributionTag = 0x0000_0800
                case cloneReferenceCount = 0x0000_1000
            }
        }
        /// A volume attribute.
        public enum Volume: UInt32, CaseIterable {
            case fileSystemType = 0x0000_0001
            case signature = 0x0000_0002
            case size = 0x0000_0004
            case freeSpace = 0x0000_0008
            case availableSpace = 0x0000_0010
            case usedSpace = 0x0080_0000
            case minimumAllocationSize = 0x0000_0020
            case allocationClumpSize = 0x0000_0040
            case ioBlockSize = 0x0000_0080
            case objectCount = 0x0000_0100
            case fileCount = 0x0000_0200
            case directoryCount = 0x0000_0400
            case maximumObjectCount = 0x0000_0800
            case mountPoint = 0x0000_1000
            case name = 0x0000_2000
            case mountFlags = 0x0000_4000
            case mountedDevice = 0x0000_8000
            case encodingsUsed = 0x0001_0000
            case capabilities = 0x0002_0000
            case uuid = 0x0004_0000
            case maximumSize = 0x1000_0000
            case minimumSize = 0x2000_0000
            case attributes = 0x4000_0000
            case fileSystemTypeName = 0x0010_0000
            case fileSystemSubtype = 0x0020_0000
        }
        /// A directory attribute.
        public enum Directory: UInt32, CaseIterable {
            case linkCount = 0x0000_0001
            case entryCount = 0x0000_0002
            case mountStatus = 0x0000_0004
            case physicalSize = 0x0000_0008
            case ioBlockSize = 0x0000_0010
            case logicalSize = 0x0000_0020
        }
        /// A file attribute.
        public enum File: UInt32, CaseIterable {
            case linkCount = 0x0000_0001
            case logicalSize = 0x0000_0002
            case physicalSize = 0x0000_0004
            case ioBlockSize = 0x0000_0008
            case clumpSize = 0x0000_0010
            case deviceType = 0x0000_0020
            case fileType = 0x0000_0040
            case forkCount = 0x0000_0080
            case forkList = 0x0000_0100
            case dataLogicalSize = 0x0000_0200
            case dataPhysicalSize = 0x0000_0400
            case dataExtents = 0x0000_0800
            case resourceLogicalSize = 0x0000_1000
            case resourcePhysicalSize = 0x0000_2000
            case resourceExtents = 0x0000_4000
        }
        /// A fork attribute.
        /// - Warning: Fork attributes are deprecated. They are documented here for historical purposes.
        @available(*, deprecated)
        public enum Fork: UInt32, CaseIterable {
            case logicalSize = 0x0000_0001
            case physicalSize = 0x0000_0002
        }
    }
}
