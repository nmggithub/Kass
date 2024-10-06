import Darwin.POSIX

extension BSD.FSCommonAttributes: BSD.FSParseableAttribute {
    public func parse(from pointer: inout UnsafeRawPointer) -> Any {
        switch self {
        case .name: pointer.getAttributeReference().parse(withParser: .string)
        case .deviceID: pointer.parseAttribute(as: dev_t.self)
        case .filesystemID: pointer.parseAttribute(as: fsid_t.self)
        case .objectType: pointer.parseAttribute(as: fsobj_type_t.self)
        case .objectTag: pointer.parseAttribute(as: fsobj_tag_t.self)
        case .objectID: pointer.parseAttribute(as: fsobj_id_t.self)
        case .objectPermanentID: pointer.parseAttribute(as: fsobj_id_t.self)
        case .parentObjectID: pointer.parseAttribute(as: fsobj_id_t.self)
        case .textEncoding: pointer.parseAttribute(as: text_encoding_t.self)
        case .creationTime: pointer.parseAttribute(as: timespec.self)
        case .modificationTime: pointer.parseAttribute(as: timespec.self)
        case .changeTime: pointer.parseAttribute(as: timespec.self)
        case .accessTime: pointer.parseAttribute(as: timespec.self)
        case .backupTime: pointer.parseAttribute(as: timespec.self)
        case .finderInfo: pointer.getAttributeReference()
        case .ownerID: pointer.parseAttribute(as: uid_t.self)
        case .groupID: pointer.parseAttribute(as: gid_t.self)
        case .accessMask: pointer.parseAttribute(as: UInt32.self) & UInt32(~S_IFMT)
        case .flags: pointer.parseAttribute(as: UInt32.self)
        case .generationCount: pointer.parseAttribute(as: UInt32.self)
        case .documentID: pointer.parseAttribute(as: UInt32.self)
        case .userAccess: pointer.parseAttribute(as: UInt32.self)
        case .extendedSecurity: pointer.getAttributeReference()
        case .ownerUUID: pointer.parseAttribute(as: guid_t.self)
        case .groupUUID: pointer.parseAttribute(as: guid_t.self)
        case .fileID: pointer.parseAttribute(as: UInt64.self)
        case .parentID: pointer.parseAttribute(as: UInt64.self)
        case .fullPath: pointer.getAttributeReference().parse(withParser: .string)
        case .addedTime: pointer.parseAttribute(as: timespec.self)
        case .dataProtectionClass: pointer.parseAttribute(as: UInt32.self)
        case .returnedAttributes: fatalError("This should not be parsed")
        default: fatalError("Unsupported common attribute: \(self)")
        }
    }
}
