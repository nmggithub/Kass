import Darwin.POSIX

extension BSD.FS.Attribute.Directory: BSD.FS.Attribute.Parseable {
    public func parse(from pointer: inout UnsafeRawPointer) -> Any {
        let value: Any =
            switch self {
            case .linkCount: pointer.load(as: UInt32.self)
            case .entryCount: pointer.load(as: UInt32.self)
            case .mountStatus: pointer.load(as: UInt32.self)
            case .physicalSize: pointer.load(as: off_t.self)
            case .ioBlockSize: pointer.load(as: UInt32.self)
            case .logicalSize: pointer.load(as: off_t.self)
            }
        pointer += MemoryLayout.size(ofValue: value)
        return value
    }
}
