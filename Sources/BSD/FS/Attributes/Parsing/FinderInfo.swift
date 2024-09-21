import Carbon

extension BSD.FS {
    /// Finder Info about a file.
    public struct FinderFileInfo: BitwiseCopyable {
        /// The file info.
        public let info: FndrFileInfo
        /// The extended file info.
        public let extendedInfo: FndrExtendedFileInfo
        /// Creates a new Finder Info representation about a file.
        /// - Parameters:
        ///   - info: The file info.
        ///   - extendedInfo: The extended file info.
        public init(info: FndrFileInfo, extendedInfo: FndrExtendedFileInfo) {
            self.info = info
            self.extendedInfo = extendedInfo
        }
    }
    /// Finder Info about a directory.
    public struct FinderDirectoryInfo: BitwiseCopyable {
        /// The directory info.
        public let info: FndrDirInfo
        /// The extended directory info.
        public let extendedInfo: FndrExtendedDirInfo
        /// Creates a new Finder Info representation about a directory.
        /// - Parameters:
        ///   - info: The directory info.
        ///   - extendedInfo: The extended directory info.
        public init(info: FndrDirInfo, extendedInfo: FndrExtendedDirInfo) {
            self.info = info
            self.extendedInfo = extendedInfo
        }
    }
}

extension BSD.FS.Attribute.Reference.Parser {
    /// A parser for Finder Info about a file.
    public static var finderFileInfo: BSD.FS.Attribute.Reference.Parser<BSD.FS.FinderFileInfo> {
        BSD.FS.Attribute.Reference.Parser<BSD.FS.FinderFileInfo> { data in
            guard
                data.count == MemoryLayout<FndrFileInfo>.size
                    + MemoryLayout<FndrExtendedFileInfo>.size
            else {
                fatalError("Invalid Finder Info data size")
            }
            let info = data.withUnsafeBytes { $0.load(as: FndrFileInfo.self) }
            let extendedInfo = data.advanced(by: MemoryLayout<FndrFileInfo>.size).withUnsafeBytes {
                $0.load(as: FndrExtendedFileInfo.self)
            }
            return BSD.FS.FinderFileInfo(info: info, extendedInfo: extendedInfo)
        }
    }
    /// A parser for Finder Info about a directory.
    public static var finderDirectoryInfo:
        BSD.FS.Attribute.Reference.Parser<BSD.FS.FinderDirectoryInfo>
    {
        BSD.FS.Attribute.Reference.Parser<BSD.FS.FinderDirectoryInfo> { data in
            guard
                data.count == MemoryLayout<FndrDirInfo>.size
                    + MemoryLayout<FndrExtendedDirInfo>.size
            else {
                fatalError("Invalid Finder Info data size")
            }
            let info = data.withUnsafeBytes { $0.load(as: FndrDirInfo.self) }
            let extendedInfo = data.advanced(by: MemoryLayout<FndrDirInfo>.size).withUnsafeBytes {
                $0.load(as: FndrExtendedDirInfo.self)
            }
            return BSD.FS.FinderDirectoryInfo(info: info, extendedInfo: extendedInfo)
        }
    }
}
