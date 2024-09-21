@_exported import BSDBase
import Darwin.POSIX

extension BSD {
    /// File system operations.
    public struct FS: Namespace {
        /// A file system ID.
        public struct ID: RawRepresentable {
            /// The raw file system ID.
            public var rawValue: fsid_t {
                fsid_t(val: (id.0, id.1))
            }
            /// Represents an existing raw file system ID.
            /// - Parameter rawValue: The raw file system ID.
            public init(rawValue: fsid_t) {
                self.id = (rawValue.val.0, rawValue.val.1)
            }
            /// The ID.
            public let id: (Int32, Int32)
        }
        /// A file system object ID.
        public struct ObjectID: RawRepresentable {
            /// The raw file system object ID.
            public var rawValue: fsobj_id {
                fsobj_id(fid_objno: objectNumber, fid_generation: generation)
            }
            /// Represents an existing raw file system object ID.
            /// - Parameter rawValue: The raw file system object ID.
            public init(rawValue: fsobj_id) {
                self.objectNumber = rawValue.fid_objno
                self.generation = rawValue.fid_generation
            }
            /// The object number.
            public let objectNumber: UInt32
            /// The generation.
            public let generation: UInt32
        }
    }
}
