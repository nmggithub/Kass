import Darwin.POSIX

extension BSD.FS.Attribute.File: BSD.FS.Attribute.Parseable {
    public func parse(from pointer: inout UnsafeRawPointer) -> Any {
        let value: Any =
            switch self {
            case .linkCount: pointer.load(as: UInt32.self)
            case .logicalSize: pointer.load(as: off_t.self)
            case .physicalSize: pointer.load(as: off_t.self)
            case .ioBlockSize: pointer.load(as: UInt32.self)
            case .clumpSize: pointer.load(as: UInt32.self)
            case .deviceType: pointer.load(as: UInt32.self)
            case .fileType: pointer.load(as: UInt32.self)
            case .forkCount: pointer.load(as: UInt32.self)
            case .forkList: pointer.load(as: attrreference.self)
            case .dataLogicalSize: pointer.load(as: off_t.self)
            case .dataPhysicalSize: pointer.load(as: off_t.self)
            case .dataExtents: pointer.load(as: extentrecord.self)
            case .resourceLogicalSize: pointer.load(as: off_t.self)
            case .resourcePhysicalSize: pointer.load(as: off_t.self)
            case .resourceExtents: pointer.load(as: extentrecord.self)
            }
        pointer += MemoryLayout.size(ofValue: value)
        return switch self {
        case .forkList:
            Self.data(from: pointer.assumingMemoryBound(to: attrreference.self))
        default: value
        }
    }
}
