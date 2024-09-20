import Darwin.POSIX

extension BSD.FS.Attribute.Common.Extended: BSD.FS.Attribute.Parseable {
    public func parse(from pointer: inout UnsafeRawPointer) -> Any {
        switch self {
        case .relativePath: pointer.getAttributeReference().parse(with: .string)
        case .privateSize: pointer.parseAttribute(as: off_t.self)
        case .linkID: pointer.parseAttribute(as: UInt64.self)
        case .pathWithNoFirmlinks: pointer.getAttributeReference().parse(with: .string)
        case .realDeviceID: pointer.parseAttribute(as: dev_t.self)
        case .realFilesystemID: pointer.parseAttribute(as: fsid_t.self)
        case .cloneID: pointer.parseAttribute(as: UInt64.self)
        case .extraFlags: pointer.parseAttribute(as: UInt64.self)
        case .recursiveGenerationCount:
            pointer.parseAttribute(as: UInt64.self)
        case .attributionTag: pointer.parseAttribute(as: UInt64.self)
        case .cloneReferenceCount: pointer.parseAttribute(as: UInt32.self)
        }
    }
}
