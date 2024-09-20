import Darwin.POSIX

extension BSD.FS.Attribute.Directory: BSD.FS.Attribute.Parseable {
    public func parse(from pointer: inout UnsafeRawPointer) -> Any {
        switch self {
        case .linkCount: pointer.parseAttribute(as: UInt32.self)
        case .entryCount: pointer.parseAttribute(as: UInt32.self)
        case .mountStatus: pointer.parseAttribute(as: UInt32.self)
        case .physicalSize: pointer.parseAttribute(as: off_t.self)
        case .ioBlockSize: pointer.parseAttribute(as: UInt32.self)
        case .logicalSize: pointer.parseAttribute(as: off_t.self)
        }
    }
}
