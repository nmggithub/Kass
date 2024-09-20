import Darwin.POSIX

extension BSD.FS.Attribute.Volume: BSD.FS.Attribute.Parseable {
    public func parse(from pointer: inout UnsafeRawPointer) -> Any {
        let value: Any =
            switch self {
            case .fileSystemType: pointer.load(as: UInt32.self)
            case .signature: pointer.load(as: UInt32.self)
            case .size: pointer.load(as: off_t.self)
            case .freeSpace: pointer.load(as: off_t.self)
            case .availableSpace: pointer.load(as: off_t.self)
            case .usedSpace: pointer.load(as: off_t.self)
            case .minimumAllocationSize: pointer.load(as: off_t.self)
            case .allocationClumpSize: pointer.load(as: off_t.self)
            case .ioBlockSize: pointer.load(as: UInt32.self)
            case .objectCount: pointer.load(as: UInt32.self)
            case .fileCount: pointer.load(as: UInt32.self)
            case .directoryCount: pointer.load(as: UInt32.self)
            case .maximumObjectCount: pointer.load(as: UInt32.self)
            case .mountPoint: pointer.load(as: attrreference.self)
            case .name: pointer.load(as: attrreference.self)
            case .mountFlags: pointer.load(as: UInt32.self)
            case .mountedDevice: pointer.load(as: attrreference.self)
            case .encodingsUsed: pointer.load(as: UInt64.self)
            case .capabilities: pointer.load(as: vol_capabilities_attr_t.self)
            case .uuid: pointer.load(as: uuid_t.self)
            case .maximumSize: pointer.load(as: off_t.self)
            case .minimumSize: pointer.load(as: off_t.self)
            case .attributes: pointer.load(as: vol_attributes_attr_t.self)
            case .fileSystemTypeName: pointer.load(as: attrreference.self)
            case .fileSystemSubtype: pointer.load(as: UInt32.self)
            }
        pointer += MemoryLayout.size(ofValue: value)
        return switch self {
        case .name, .mountPoint, .mountedDevice, .fileSystemTypeName:
            String(
                data: Self.data(from: pointer.assumingMemoryBound(to: attrreference.self)),
                encoding: .utf8
            )!
        default: value
        }
    }
}
