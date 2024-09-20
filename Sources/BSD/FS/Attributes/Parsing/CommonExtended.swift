import Darwin.POSIX

extension BSD.FS.Attribute.Common.Extended: BSD.FS.Attribute.Parseable {
    public func parse(from pointer: inout UnsafeRawPointer) -> Any {
        let value: Any =
            switch self {
            case .relativePath: pointer.load(as: attrreference.self)
            case .privateSize: pointer.load(as: off_t.self)
            case .linkID: pointer.load(as: UInt64.self)
            case .pathWithNoFirmlinks: pointer.load(as: attrreference.self)
            case .realDeviceID: pointer.load(as: dev_t.self)
            case .realFilesystemID: pointer.load(as: fsid_t.self)
            case .cloneID: pointer.load(as: UInt64.self)
            case .extraFlags: pointer.load(as: UInt64.self)
            case .recursiveGenerationCount: pointer.load(as: UInt64.self)
            case .attributionTag: pointer.load(as: UInt64.self)
            case .cloneReferenceCount: pointer.load(as: UInt32.self)
            }
        pointer += MemoryLayout.size(ofValue: value)
        return switch self {
        case .relativePath, .pathWithNoFirmlinks:
            String(
                data: Self.data(from: pointer.assumingMemoryBound(to: attrreference.self)),
                encoding: .utf8
            )!
        default: value
        }
    }
}
