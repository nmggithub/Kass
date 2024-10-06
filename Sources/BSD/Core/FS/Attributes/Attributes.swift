import CCompat  // for bitmap functions
import Darwin.POSIX
import Darwin.sys.attr
import Foundation
import KassHelpers
import System

extension BSD {
    /// A collection of attributes.
    protocol FSAttributes: OptionSet, Sendable, Hashable, CaseIterable, KassHelpers.NamedOptionEnum
    where RawValue == UInt32 {
        /// The individual attributed in the collection.
        var attributes: [Self.Element] { get }
    }
}

extension BSD {
    // IMPORTANT: The order of the `allCases` arrays is important. They must be in the same order as the ones in the
    // `getattrlist` manpage. We use this order to ensure we parse the returned attributes in the correct order.

    // MARK: - Common Attributes
    /// Common attribute.
    public struct FSCommonAttributes: BSD.FSAttributes {
        /// The name of the common attributes, if it can be determined.
        public let name: String?

        /// Represents common attributes with an optional name.
        public init(name: String?, rawValue: UInt32) {
            self.name = name
            self.rawValue = rawValue & UInt32(ATTR_CMN_VALIDMASK)
        }

        /// The raw value of the common attributes.
        public let rawValue: UInt32

        /// The individual common attributes in the collection.
        public var attributes: [Self] { Self.allCases.filter { self.contains($0) } }

        /// All known common attributes.
        public static let allCases: [Self] = [
            .returnedAttributes,
            .name,
            .deviceID,
            .filesystemID,
            .objectType,
            .objectTag,
            .objectID,
            .objectPermanentID,
            .parentObjectID,
            .textEncoding,
            .creationTime,
            .modificationTime,
            .changeTime,
            .accessTime,
            .backupTime,
            .finderInfo,
            .ownerID,
            .groupID,
            .accessMask,
            .flags,
            .generationCount,
            .documentID,
            .userAccess,
            .extendedSecurity,
            .ownerUUID,
            .groupUUID,
            .fileID,
            .parentID,
            .fullPath,
            .addedTime,
            .dataProtectionClass,
        ]

        public static let returnedAttributes = Self(
            name: "returnedAttributes", rawValue: UInt32(ATTR_CMN_RETURNED_ATTRS)
        )

        public static let name = Self(name: "name", rawValue: UInt32(ATTR_CMN_NAME))

        public static let deviceID = Self(name: "deviceID", rawValue: UInt32(ATTR_CMN_DEVID))

        public static let filesystemID = Self(name: "filesystemID", rawValue: UInt32(ATTR_CMN_FSID))

        public static let objectType = Self(name: "objectType", rawValue: UInt32(ATTR_CMN_OBJTYPE))

        public static let objectTag = Self(name: "objectTag", rawValue: UInt32(ATTR_CMN_OBJTAG))

        public static let objectID = Self(name: "objectID", rawValue: UInt32(ATTR_CMN_OBJID))

        public static let objectPermanentID = Self(
            name: "objectPermanentID", rawValue: UInt32(ATTR_CMN_OBJPERMANENTID)
        )

        public static let parentObjectID = Self(
            name: "parentObjectID", rawValue: UInt32(ATTR_CMN_PAROBJID)
        )

        public static let textEncoding = Self(
            name: "textEncoding", rawValue: UInt32(ATTR_CMN_SCRIPT)
        )

        public static let creationTime = Self(
            name: "creationTime", rawValue: UInt32(ATTR_CMN_CRTIME)
        )

        public static let modificationTime = Self(
            name: "modificationTime", rawValue: UInt32(ATTR_CMN_MODTIME)
        )

        public static let changeTime = Self(
            name: "changeTime", rawValue: UInt32(ATTR_CMN_CHGTIME)
        )

        public static let accessTime = Self(
            name: "accessTime", rawValue: UInt32(ATTR_CMN_ACCTIME)
        )

        public static let backupTime = Self(
            name: "backupTime", rawValue: UInt32(ATTR_CMN_BKUPTIME)
        )

        public static let finderInfo = Self(
            name: "finderInfo", rawValue: UInt32(ATTR_CMN_FNDRINFO)
        )

        public static let ownerID = Self(
            name: "ownerID", rawValue: UInt32(ATTR_CMN_OWNERID)
        )

        public static let groupID = Self(
            name: "groupID", rawValue: UInt32(ATTR_CMN_GRPID)
        )

        public static let accessMask = Self(
            name: "accessMask", rawValue: UInt32(ATTR_CMN_ACCESSMASK)
        )

        public static let flags = Self(
            name: "flags", rawValue: UInt32(ATTR_CMN_FLAGS)
        )

        public static let generationCount = Self(
            name: "generationCount", rawValue: UInt32(ATTR_CMN_GEN_COUNT)
        )

        public static let documentID = Self(
            name: "documentID", rawValue: UInt32(ATTR_CMN_DOCUMENT_ID)
        )

        public static let userAccess = Self(
            name: "userAccess", rawValue: UInt32(ATTR_CMN_USERACCESS)
        )

        public static let extendedSecurity = Self(
            name: "extendedSecurity", rawValue: UInt32(ATTR_CMN_EXTENDED_SECURITY)
        )

        public static let ownerUUID = Self(
            name: "ownerUUID", rawValue: UInt32(ATTR_CMN_UUID)
        )

        public static let groupUUID = Self(
            name: "groupUUID", rawValue: UInt32(ATTR_CMN_GRPUUID)
        )

        public static let fileID = Self(
            name: "fileID", rawValue: UInt32(ATTR_CMN_FILEID)
        )

        public static let parentID = Self(
            name: "parentID", rawValue: UInt32(ATTR_CMN_PARENTID)
        )

        public static let fullPath = Self(
            name: "fullPath", rawValue: UInt32(ATTR_CMN_FULLPATH)
        )

        public static let addedTime = Self(
            name: "addedTime", rawValue: UInt32(ATTR_CMN_ADDEDTIME)
        )

        public static let dataProtectionClass = Self(
            name: "dataProtectionClass", rawValue: UInt32(ATTR_CMN_DATA_PROTECT_FLAGS)
        )
    }

    // MARK: - Volume Attributes
    /// Volume attributes.
    public struct FSVolumeAttributes: BSD.FSAttributes {
        /// The name of the volume attributes, if it can be determined.
        public let name: String?

        /// Represents volume attributes with an optional name.
        public init(name: String?, rawValue: UInt32) {
            self.name = name
            self.rawValue = rawValue & UInt32(ATTR_VOL_VALIDMASK)
        }

        /// The raw value of the volume attributes.
        public let rawValue: UInt32

        /// The individual volume attributes in the collection.
        public var attributes: [Self] { Self.allCases.filter { self.contains($0) } }

        /// All known volume attributes.
        public static let allCases: [Self] = [
            .fileSystemType,
            .signature,
            .size,
            .freeSpace,
            .availableSpace,
            .usedSpace,
            .minimumAllocationSize,
            .allocationClumpSize,
            .ioBlockSize,
            .objectCount,
            .fileCount,
            .directoryCount,
            .maximumObjectCount,
            .mountPoint,
            .name,
            .mountFlags,
            .mountedDevice,
            .encodingsUsed,
            .capabilities,
            .uuid,
            .maximumSize,
            .minimumSize,
            .attributes,
            .fileSystemTypeName,
            .fileSystemSubtype,
        ]

        public static let fileSystemType = Self(
            name: "fileSystemType", rawValue: UInt32(ATTR_VOL_FSTYPE)
        )

        public static let signature = Self(
            name: "signature", rawValue: UInt32(ATTR_VOL_SIGNATURE)
        )

        public static let size = Self(
            name: "size", rawValue: UInt32(ATTR_VOL_SIZE)
        )

        public static let freeSpace = Self(
            name: "freeSpace", rawValue: UInt32(ATTR_VOL_SPACEFREE)
        )

        public static let availableSpace = Self(
            name: "availableSpace", rawValue: UInt32(ATTR_VOL_SPACEAVAIL)
        )

        public static let usedSpace = Self(
            name: "usedSpace", rawValue: UInt32(ATTR_VOL_SPACEUSED)
        )

        public static let minimumAllocationSize = Self(
            name: "minimumAllocationSize", rawValue: UInt32(ATTR_VOL_MINALLOCATION)
        )

        public static let allocationClumpSize = Self(
            name: "allocationClumpSize", rawValue: UInt32(ATTR_VOL_ALLOCATIONCLUMP)
        )

        public static let ioBlockSize = Self(
            name: "ioBlockSize", rawValue: UInt32(ATTR_VOL_IOBLOCKSIZE)
        )

        public static let objectCount = Self(
            name: "objectCount", rawValue: UInt32(ATTR_VOL_OBJCOUNT)
        )

        public static let fileCount = Self(
            name: "fileCount", rawValue: UInt32(ATTR_VOL_FILECOUNT)
        )

        public static let directoryCount = Self(
            name: "directoryCount", rawValue: UInt32(ATTR_VOL_DIRCOUNT)
        )

        public static let maximumObjectCount = Self(
            name: "maximumObjectCount", rawValue: UInt32(ATTR_VOL_MAXOBJCOUNT)
        )

        public static let mountPoint = Self(
            name: "mountPoint", rawValue: UInt32(ATTR_VOL_MOUNTPOINT)
        )

        public static let name = Self(
            name: "name", rawValue: UInt32(ATTR_VOL_NAME)
        )

        public static let mountFlags = Self(
            name: "mountFlags", rawValue: UInt32(ATTR_VOL_MOUNTFLAGS)
        )

        public static let mountedDevice = Self(
            name: "mountedDevice", rawValue: UInt32(ATTR_VOL_MOUNTEDDEVICE)
        )

        public static let encodingsUsed = Self(
            name: "encodingsUsed", rawValue: UInt32(ATTR_VOL_ENCODINGSUSED)
        )

        public static let capabilities = Self(
            name: "capabilities", rawValue: UInt32(ATTR_VOL_CAPABILITIES)
        )

        public static let uuid = Self(
            name: "uuid", rawValue: UInt32(ATTR_VOL_UUID)
        )

        public static let maximumSize = Self(
            name: "maximumSize", rawValue: UInt32(ATTR_VOL_QUOTA_SIZE)
        )

        public static let minimumSize = Self(
            name: "minimumSize", rawValue: UInt32(ATTR_VOL_RESERVED_SIZE)
        )

        public static let attributes = Self(
            name: "attributes", rawValue: UInt32(ATTR_VOL_ATTRIBUTES)
        )

        public static let fileSystemTypeName = Self(
            name: "fileSystemTypeName", rawValue: UInt32(ATTR_VOL_FSTYPENAME)
        )

        public static let fileSystemSubtype = Self(
            name: "fileSystemSubtype", rawValue: UInt32(ATTR_VOL_FSSUBTYPE)
        )
    }

    // MARK: - Directory Attributes
    /// Directory attributes.
    public struct FSDirectoryAttributes: BSD.FSAttributes {
        /// The name of the directory attributes, if it can be determined.
        public let name: String?

        /// Represents directory attributes with an optional name.
        public init(name: String?, rawValue: UInt32) {
            self.name = name
            self.rawValue = rawValue & UInt32(ATTR_DIR_VALIDMASK)
        }

        /// The raw value of the directory attributes.
        public let rawValue: UInt32

        /// The individual directory attributes in the collection.
        public var attributes: [Self] { Self.allCases.filter { self.contains($0) } }

        /// All known directory attributes.
        public static let allCases: [Self] = [
            .linkCount,
            .entryCount,
            .mountStatus,
            .physicalSize,
            .ioBlockSize,
            .logicalSize,
        ]

        public static let linkCount = Self(
            name: "linkCount", rawValue: UInt32(ATTR_DIR_LINKCOUNT)
        )

        public static let entryCount = Self(
            name: "entryCount", rawValue: UInt32(ATTR_DIR_ENTRYCOUNT)
        )

        public static let mountStatus = Self(
            name: "mountStatus", rawValue: UInt32(ATTR_DIR_MOUNTSTATUS)
        )

        public static let physicalSize = Self(
            name: "physicalSize", rawValue: UInt32(ATTR_DIR_ALLOCSIZE)
        )

        public static let ioBlockSize = Self(
            name: "ioBlockSize", rawValue: UInt32(ATTR_DIR_ENTRYCOUNT)
        )

        public static let logicalSize = Self(
            name: "logicalSize", rawValue: UInt32(ATTR_DIR_DATALENGTH)
        )
    }

    // MARK: - File Attributes
    /// File attributes.
    public struct FSFileAttributes: BSD.FSAttributes {
        /// The name of the file attributes, if it can be determined.
        public let name: String?

        /// Represents file attributes with an optional name.
        public init(name: String?, rawValue: UInt32) {
            self.name = name
            self.rawValue = rawValue & UInt32(ATTR_FILE_VALIDMASK)
        }

        /// The raw value of the file attributes.
        public let rawValue: UInt32

        /// The individual file attributes in the collection.
        public var attributes: [Self] { Self.allCases.filter { self.contains($0) } }

        /// All known file attributes.
        public static let allCases: [Self] = [
            .linkCount,
            .logicalSize,
            .physicalSize,
            .ioBlockSize,
            .clumpSize,
            .deviceType,
            .fileType,
            .forkCount,
            .forkList,
            .dataLogicalSize,
            .dataPhysicalSize,
            .dataExtents,
            .resourceLogicalSize,
            .resourcePhysicalSize,
            .resourceExtents,
        ]

        public static let linkCount = Self(
            name: "linkCount", rawValue: UInt32(ATTR_FILE_LINKCOUNT)
        )

        public static let logicalSize = Self(
            name: "logicalSize", rawValue: UInt32(ATTR_FILE_TOTALSIZE)
        )

        public static let physicalSize = Self(
            name: "physicalSize", rawValue: UInt32(ATTR_FILE_ALLOCSIZE)
        )

        public static let ioBlockSize = Self(
            name: "ioBlockSize", rawValue: UInt32(ATTR_FILE_IOBLOCKSIZE)
        )

        public static let clumpSize = Self(
            name: "clumpSize", rawValue: UInt32(ATTR_FILE_CLUMPSIZE)
        )

        public static let deviceType = Self(
            name: "deviceType", rawValue: UInt32(ATTR_FILE_DEVTYPE)
        )

        public static let fileType = Self(
            name: "fileType", rawValue: UInt32(ATTR_FILE_FILETYPE)
        )

        public static let forkCount = Self(
            name: "forkCount", rawValue: UInt32(ATTR_FILE_FORKCOUNT)
        )

        public static let forkList = Self(
            name: "forkList", rawValue: UInt32(ATTR_FILE_FORKLIST)
        )

        public static let dataLogicalSize = Self(
            name: "dataLogicalSize", rawValue: UInt32(ATTR_FILE_DATALENGTH)
        )

        public static let dataPhysicalSize = Self(
            name: "dataPhysicalSize", rawValue: UInt32(ATTR_FILE_DATAALLOCSIZE)
        )

        public static let dataExtents = Self(
            name: "dataExtents", rawValue: UInt32(ATTR_FILE_DATAEXTENTS)
        )

        public static let resourceLogicalSize = Self(
            name: "resourceLogicalSize", rawValue: UInt32(ATTR_FILE_RSRCLENGTH)
        )

        public static let resourcePhysicalSize = Self(
            name: "resourcePhysicalSize", rawValue: UInt32(ATTR_FILE_RSRCALLOCSIZE)
        )

        public static let resourceExtents = Self(
            name: "resourceExtents", rawValue: UInt32(ATTR_FILE_RSRCEXTENTS)
        )
    }

    // MARK: - Extended Common Attributes
    /// Extended common attributes.
    public struct FSCommonExtendedAttributes: BSD.FSAttributes {
        /// The name of the extended common attributes, if it can be determined.
        public let name: String?

        /// Represents extended common attributes with an optional name.
        public init(name: String?, rawValue: UInt32) {
            self.name = name
            self.rawValue = rawValue & UInt32(ATTR_CMNEXT_VALIDMASK)
        }

        /// The raw value of the extended common attributes.
        public let rawValue: UInt32

        /// The individual extended common attributes in the collection.
        public var attributes: [Self] { Self.allCases.filter { self.contains($0) } }

        /// All known extended common attributes.
        public static let allCases: [Self] = [
            .relativePath,
            .privateSize,
            .linkID,
            .pathWithNoFirmlinks,
            .realDeviceID,
            .realFilesystemID,
            .cloneID,
            .extraFlags,
            .recursiveGenerationCount,
            .attributionTag,
            .cloneReferenceCount,
        ]

        public static let relativePath = Self(
            name: "relativePath", rawValue: UInt32(ATTR_CMNEXT_RELPATH)
        )

        public static let privateSize = Self(
            name: "privateSize", rawValue: UInt32(ATTR_CMNEXT_PRIVATESIZE)
        )

        public static let linkID = Self(
            name: "linkID", rawValue: UInt32(ATTR_CMNEXT_LINKID)
        )

        public static let pathWithNoFirmlinks = Self(
            name: "pathWithNoFirmlinks", rawValue: UInt32(ATTR_CMNEXT_NOFIRMLINKPATH)
        )

        public static let realDeviceID = Self(
            name: "realDeviceID", rawValue: UInt32(ATTR_CMNEXT_REALDEVID)
        )

        public static let realFilesystemID = Self(
            name: "realFilesystemID", rawValue: UInt32(ATTR_CMNEXT_REALFSID)
        )

        public static let cloneID = Self(
            name: "cloneID", rawValue: UInt32(ATTR_CMNEXT_CLONEID)
        )

        public static let extraFlags = Self(
            name: "extraFlags", rawValue: UInt32(ATTR_CMNEXT_EXT_FLAGS)
        )

        public static let recursiveGenerationCount = Self(
            name: "recursiveGenerationCount", rawValue: UInt32(ATTR_CMNEXT_RECURSIVE_GENCOUNT)
        )

        public static let attributionTag = Self(
            name: "attributionTag", rawValue: UInt32(ATTR_CMNEXT_ATTRIBUTION_TAG)
        )

        public static let cloneReferenceCount = Self(
            name: "cloneReferenceCount", rawValue: UInt32(ATTR_CMNEXT_CLONE_REFCNT)
        )
    }
}
