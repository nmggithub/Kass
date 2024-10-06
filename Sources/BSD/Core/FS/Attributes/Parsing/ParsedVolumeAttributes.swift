import Darwin.POSIX

extension BSD.FSVolumeAttributes: BSD.FSParseableAttribute {
    public func parse(from pointer: inout UnsafeRawPointer) -> Any {
        switch self {
        case .fileSystemType: pointer.parseAttribute(as: UInt32.self)
        case .signature: pointer.parseAttribute(as: UInt32.self)
        case .size: pointer.parseAttribute(as: off_t.self)
        case .freeSpace: pointer.parseAttribute(as: off_t.self)
        case .availableSpace: pointer.parseAttribute(as: off_t.self)
        case .usedSpace: pointer.parseAttribute(as: off_t.self)
        case .minimumAllocationSize: pointer.parseAttribute(as: off_t.self)
        case .allocationClumpSize: pointer.parseAttribute(as: off_t.self)
        case .ioBlockSize: pointer.parseAttribute(as: UInt32.self)
        case .objectCount: pointer.parseAttribute(as: UInt32.self)
        case .fileCount: pointer.parseAttribute(as: UInt32.self)
        case .directoryCount: pointer.parseAttribute(as: UInt32.self)
        case .maximumObjectCount: pointer.parseAttribute(as: UInt32.self)
        case .mountPoint: pointer.getAttributeReference().parse(withParser: .string)
        case .name: pointer.getAttributeReference().parse(withParser: .string)
        case .mountFlags: pointer.parseAttribute(as: UInt32.self)
        case .mountedDevice: pointer.getAttributeReference().parse(withParser: .string)
        case .encodingsUsed: pointer.parseAttribute(as: UInt64.self)
        case .capabilities: pointer.parseAttribute(as: vol_capabilities_attr_t.self)
        case .uuid: pointer.parseAttribute(as: uuid_t.self)
        case .maximumSize: pointer.parseAttribute(as: off_t.self)
        case .minimumSize: pointer.parseAttribute(as: off_t.self)
        case .attributes: pointer.parseAttribute(as: vol_attributes_attr_t.self)
        case .fileSystemTypeName: pointer.getAttributeReference().parse(withParser: .string)
        case .fileSystemSubtype: pointer.parseAttribute(as: UInt32.self)
        default: fatalError("Unsupported volume attribute: \(self)")
        }
    }
}
