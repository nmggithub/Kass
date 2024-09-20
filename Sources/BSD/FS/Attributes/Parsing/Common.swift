import Darwin.POSIX

extension BSD.FS.Attribute.Common: BSD.FS.Attribute.Parseable {
    public func parse(from pointer: inout UnsafeRawPointer) -> Any {
        let value: Any =
            switch self {
            case .name: pointer.load(as: attrreference.self)
            case .deviceID: pointer.load(as: dev_t.self)
            case .filesystemID: pointer.load(as: fsid_t.self)
            case .objectType: pointer.load(as: fsobj_type_t.self)
            case .objectTag: pointer.load(as: fsobj_tag_t.self)
            case .objectID: pointer.load(as: fsobj_id_t.self)
            case .objectPermanentID: pointer.load(as: fsobj_id_t.self)
            case .parentObjectID: pointer.load(as: fsobj_id_t.self)
            case .textEncoding: pointer.load(as: text_encoding_t.self)
            case .creationTime: pointer.load(as: timespec.self)
            case .modificationTime: pointer.load(as: timespec.self)
            case .changeTime: pointer.load(as: timespec.self)
            case .accessTime: pointer.load(as: timespec.self)
            case .backupTime: pointer.load(as: timespec.self)
            case .finderInfo: pointer.load(as: attrreference.self)
            case .ownerID: pointer.load(as: uid_t.self)
            case .groupID: pointer.load(as: gid_t.self)
            case .accessMask: pointer.load(as: mode_t.self) & ~S_IFMT
            case .flags: pointer.load(as: UInt32.self)
            case .generationCount: pointer.load(as: UInt32.self)
            case .documentID: pointer.load(as: UInt32.self)
            case .userAccess: pointer.load(as: UInt32.self)
            case .extendedSecurity: pointer.load(as: attrreference.self)
            case .ownerUUID: pointer.load(as: guid_t.self)
            case .groupUUID: pointer.load(as: guid_t.self)
            case .fileID: pointer.load(as: UInt64.self)
            case .parentID: pointer.load(as: UInt64.self)
            case .fullPath: pointer.load(as: attrreference.self)
            case .addedTime: pointer.load(as: timespec.self)
            case .dataProtectionClass: pointer.load(as: UInt32.self)
            case .returnedAttributes: fatalError("This should not be parsed")
            }
        pointer += MemoryLayout.size(ofValue: value)
        return switch self {
        case .name, .fullPath:
            String(
                data: Self.data(from: pointer.assumingMemoryBound(to: attrreference.self)),
                encoding: .utf8
            )!
        case .finderInfo, .extendedSecurity:
            Self.data(from: pointer.assumingMemoryBound(to: attrreference.self))
        default: value
        }
    }
}
