#if os(macOS)
    import Darwin.POSIX
    import Foundation
    import KassHelpers

    extension BSD {
        /// A type of list of PIDs.
        public struct ProcPIDListType: KassHelpers.NamedOptionEnum {
            /// The name of the list type, if it can be determined.
            public var name: String?

            /// Represents a list type with an optional name.
            public init(name: String?, rawValue: UInt32) {
                self.name = name
                self.rawValue = rawValue
            }

            /// The raw value of the list type.
            public let rawValue: UInt32

            /// All known list types.
            public static let allCases: [Self] = [
                .all,
                .processGroupOnly,
                .ttyOnly,
                .uidOnly,
                .realUIDOnly,
                .parentPIDOnly,
                .kernelDebugOnly,
            ]

            public static let all = Self(
                name: "allPIDs", rawValue: UInt32(PROC_ALL_PIDS)
            )

            public static let processGroupOnly = Self(
                name: "processGroupOnly", rawValue: UInt32(PROC_PGRP_ONLY)
            )

            public static let ttyOnly = Self(
                name: "ttyOnly", rawValue: UInt32(PROC_TTY_ONLY)
            )

            public static let uidOnly = Self(
                name: "uidOnly", rawValue: UInt32(PROC_UID_ONLY)
            )

            public static let realUIDOnly = Self(
                name: "realUIDOnly", rawValue: UInt32(PROC_RUID_ONLY)
            )

            public static let parentPIDOnly = Self(
                name: "parentPIDOnly", rawValue: UInt32(PROC_PPID_ONLY)
            )

            public static let kernelDebugOnly = Self(
                name: "kernelDebugOnly", rawValue: UInt32(PROC_KDBG_ONLY)
            )
        }

        /// A description of a list of PIDs.
        public struct ProcPIDListDescription {
            /// The type of list.
            let type: ProcPIDListType

            /// The additional info for the list.
            let info: UInt32?

            /// Creates a description of a list of PIDs.
            public init(
                type: ProcPIDListType,
                info: UInt32? = nil
            ) {
                self.type = type
                self.info = info
            }
        }
    }

    extension BSD.Proc {
        /// Gets a list of PIDs.
        public static func listPIDs(
            _ list: BSDCore.BSD.ProcPIDListDescription
        ) throws -> [pid_t] {
            let maxPIDs = Data(try BSDCore.BSD.sysctl("kern.maxproc"))
                .withUnsafeBytes { $0.load(as: Int32.self) }
            let pidBuffer = UnsafeMutableBufferPointer<pid_t>.allocate(capacity: Int(maxPIDs))
            defer { pidBuffer.deallocate() }
            let returnedBufferSize = try BSDCore.BSD.call(
                proc_listpids(
                    list.type.rawValue,
                    list.info ?? 0,  // Some types don't require info, but we can't pass nil.
                    UnsafeMutableRawPointer(pidBuffer.baseAddress),
                    maxPIDs * Int32(MemoryLayout<pid_t>.size)
                )
            )
            let returnedPIDCount = returnedBufferSize / Int32(MemoryLayout<pid_t>.size)
            return Array(pidBuffer.prefix(Int(returnedPIDCount)))
        }
    }
#endif  // os(macOS)
