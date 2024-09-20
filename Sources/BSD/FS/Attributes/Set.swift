import Darwin.POSIX
import Foundation

extension BSD.FS.Attribute {
    public struct Set: RawRepresentable {
        public var rawValue: attribute_set_t {
            attribute_set_t(
                commonattr: common.bitmap(),
                // ATTR_VOL_INFO is not a real attribute, but a flag to indicate that volume attributes are requested
                volattr: volume.count > 0 ? volume.bitmap() | ATTR_VOL_INFO : 0,
                dirattr: directory.bitmap(),
                fileattr: file.bitmap(),
                forkattr: commonExtended.bitmap()
            )
        }
        public init(rawValue: attribute_set_t) {
            self.common = Common.set(from: rawValue.commonattr)
            self.volume = Volume.set(from: rawValue.volattr)
            self.directory = Directory.set(from: rawValue.dirattr)
            self.file = File.set(from: rawValue.fileattr)
            self.commonExtended = Common.Extended.set(from: rawValue.forkattr)
        }
        public init() {}
        public var common: Swift.Set<Common> = []
        public var volume: Swift.Set<Volume> = []
        public var directory: Swift.Set<Directory> = []
        public var file: Swift.Set<File> = []
        @available(*, deprecated)
        public var fork: Swift.Set<Fork> = []
        public var commonExtended: Swift.Set<Common.Extended> = []
    }
}
