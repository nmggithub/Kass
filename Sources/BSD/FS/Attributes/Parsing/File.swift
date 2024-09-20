import Darwin.POSIX

extension BSD.FS.Attribute.File: BSD.FS.Attribute.Parseable {
    public func parse(from pointer: inout UnsafeRawPointer) -> Any {
        switch self {
        case .linkCount: pointer.parseAttribute(as: UInt32.self)
        case .logicalSize: pointer.parseAttribute(as: off_t.self)
        case .physicalSize: pointer.parseAttribute(as: off_t.self)
        case .ioBlockSize: pointer.parseAttribute(as: UInt32.self)
        case .clumpSize: pointer.parseAttribute(as: UInt32.self)
        case .deviceType: pointer.parseAttribute(as: UInt32.self)
        case .fileType: pointer.parseAttribute(as: UInt32.self)
        case .forkCount: pointer.parseAttribute(as: UInt32.self)
        case .forkList: pointer.getAttributeReference()
        case .dataLogicalSize: pointer.parseAttribute(as: off_t.self)
        case .dataPhysicalSize: pointer.parseAttribute(as: off_t.self)
        case .dataExtents: pointer.parseAttribute(as: extentrecord.self)
        case .resourceLogicalSize: pointer.parseAttribute(as: off_t.self)
        case .resourcePhysicalSize: pointer.parseAttribute(as: off_t.self)
        case .resourceExtents: pointer.parseAttribute(as: extentrecord.self)
        }
    }
}
