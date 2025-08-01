#if os(macOS)
    import Darwin.POSIX
    import Foundation
    import KassC.ProcInfoPrivate
    import KassHelpers

    extension BSD {
        /// A flavor of PID fileport info.
        public struct ProcPIDFileportInfoFlavor: KassHelpers.NamedOptionEnum {
            /// The name of the flavor, if it can be determined.
            public var name: String?

            /// Represents a flavor of PID fileport info with an optional name.
            public init(name: String?, rawValue: Int32) {
                self.name = name
                self.rawValue = rawValue
            }

            /// The raw value of the flavor.
            public let rawValue: Int32

            /// All known flavors of PID fileport info.
            public static let allCases: [Self] = [
                .vnodePathInfo, .socketInfo, .posixSharedMemoryInfo, .pipeInfo,
            ]

            // MARK: - Public Flavors

            public static let vnodePathInfo = Self(
                name: "vnodePathInfo", rawValue: PROC_PIDFILEPORTVNODEPATHINFO
            )

            public static let socketInfo = Self(
                name: "socketInfo", rawValue: PROC_PIDFILEPORTSOCKETINFO
            )

            public static let posixSharedMemoryInfo = Self(
                name: "posixSharedMemoryInfo", rawValue: PROC_PIDFILEPORTPSHMINFO
            )

            public static let pipeInfo = Self(
                name: "pipeInfo", rawValue: PROC_PIDFILEPORTPIPEINFO
            )
        }

        /// A fileport in a process.
        public struct ProcPIDFileport {
            internal let pid: pid_t
            internal let fileport: BSD.Fileport

            /// Gets information about a fileport in the process.
            @discardableResult
            public func info(
                flavor: BSD.ProcPIDFileportInfoFlavor,
                bufferPointer: UnsafeMutableRawBufferPointer
            ) throws -> Int32 {
                try BSD.call(
                    proc_pidfileportinfo(
                        self.pid, self.fileport.name, flavor.rawValue,
                        bufferPointer.baseAddress, Int32(bufferPointer.count)
                    )
                )
            }

            /// Gets information about a fileport in the process.
            @discardableResult
            public func info(
                flavor: BSD.ProcPIDFileportInfoFlavor,
                buffer: inout Data
            ) throws -> Int32 {
                try buffer.withUnsafeMutableBytes {
                    try self.info(flavor: flavor, bufferPointer: $0)
                }
            }

            /// Gets information about a fileport in the process and return it as a specific type.
            @discardableResult
            public func info<DataType>(
                flavor: BSD.ProcPIDFileportInfoFlavor,
                returnAs type: DataType.Type = DataType.self
            ) throws -> DataType {
                var buffer = Data(repeating: 0, count: MemoryLayout<DataType>.size)
                try self.info(flavor: flavor, buffer: &buffer)
                return buffer.withUnsafeBytes {
                    $0.load(as: DataType.self)
                }
            }

            /// Gets information about a fileport in the process and return it as an array of a specific type.
            @discardableResult
            public func info<DataType>(
                flavor: BSD.ProcPIDFileportInfoFlavor,
                returnAs type: DataType.Type = DataType.self,
                count: Int
            ) throws -> [DataType] {
                let bufferPointer = UnsafeMutableBufferPointer<DataType>
                    .allocate(capacity: count)
                defer { bufferPointer.deallocate() }
                let rawBufferPointer = UnsafeMutableRawBufferPointer(bufferPointer)
                let returnedBufferSize = try self.info(
                    flavor: flavor, bufferPointer: rawBufferPointer)
                return Array(
                    rawBufferPointer
                        .prefix(Int(returnedBufferSize))
                        .assumingMemoryBound(to: DataType.self)
                )
            }

            // MARK: - Getters

            // MARK: - Public Flavor Getters

            public var vnodePathInfo: vnode_fdinfowithpath {
                get throws { try self.info(flavor: .vnodePathInfo) }
            }

            public var socketInfo: socket_fdinfo {
                get throws { try self.info(flavor: .socketInfo) }
            }

            public var posixSharedMemoryInfo: pshm_fdinfo {
                get throws { try self.info(flavor: .posixSharedMemoryInfo) }
            }

            public var pipeInfo: pipe_fdinfo {
                get throws { try self.info(flavor: .pipeInfo) }
            }
        }
    }

    extension BSD.Proc {
        /// Represents a fileport in the process.
        public func fileport(_ fileport: BSD.Fileport) -> BSD.ProcPIDFileport {
            BSD.ProcPIDFileport(pid: self.pid, fileport: fileport)
        }
    }
#endif  // os(macOS)
