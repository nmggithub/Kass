import Darwin.POSIX
import Foundation
import KassC.ProcInfoPrivate
import KassHelpers

extension BSD {
    /// A flavor of PID file descriptor info.
    public struct ProcPIDFDInfoFlavor: KassHelpers.NamedOptionEnum {
        /// The name of the flavor, if it can be determined.
        public var name: String?

        /// Represents a flavor of PID file descriptor info with an optional name.
        public init(name: String?, rawValue: Int32) {
            self.name = name
            self.rawValue = rawValue
        }

        /// The raw value of the flavor.
        public let rawValue: Int32

        /// All known flavors of PID file descriptor info.
        public static let allCases: [Self] = [
            .vnodeInfo, .vnodePathInfo, .socketInfo, .posixSemaphoreInfo, .posixSharedMemoryInfo,
            .pipeInfo, .kqueueInfo, .appleTalkInfo, .channelInfo, .kqueueExtInfo,
        ]

        // MARK: - Public Flavors

        public static let vnodeInfo = Self(
            name: "vnodeInfo", rawValue: PROC_PIDFDVNODEINFO
        )

        public static let vnodePathInfo = Self(
            name: "vnodePathInfo", rawValue: PROC_PIDFDVNODEPATHINFO
        )

        public static let socketInfo = Self(
            name: "socketInfo", rawValue: PROC_PIDFDSOCKETINFO
        )

        public static let posixSemaphoreInfo = Self(
            name: "posixSemaphoreInfo", rawValue: PROC_PIDFDPSEMINFO
        )

        public static let posixSharedMemoryInfo = Self(
            name: "posixSharedMemoryInfo", rawValue: PROC_PIDFDPSHMINFO
        )

        public static let pipeInfo = Self(
            name: "pipeInfo", rawValue: PROC_PIDFDPIPEINFO
        )

        public static let kqueueInfo = Self(
            name: "kqueueInfo", rawValue: PROC_PIDFDKQUEUEINFO
        )

        public static let appleTalkInfo = Self(
            name: "appleTalkInfo", rawValue: PROC_PIDFDATALKINFO
        )

        public static let channelInfo = Self(
            name: "channelInfo", rawValue: PROC_PIDFDCHANNELINFO
        )

        // MARK: - Private Flavors

        // Does "ext" stand for "extended" or "external" or something else?
        public static let kqueueExtInfo = Self(
            name: "kqueueExtInfo", rawValue: PROC_PIDFDKQUEUE_EXTINFO
        )
    }

    /// A file descriptor in a process.
    public struct ProcPIDFD {
        internal let pid: pid_t
        internal let fd: Int32

        /// Gets information about a file descriptor in the process.
        @discardableResult
        public func info(
            flavor: BSD.ProcPIDFDInfoFlavor,
            bufferPointer: UnsafeMutableRawBufferPointer
        ) throws -> Int32 {
            try BSD.call(
                proc_pidfdinfo(
                    self.pid, self.fd, flavor.rawValue,
                    bufferPointer.baseAddress, Int32(bufferPointer.count)
                )
            )
        }

        /// Gets information about a file descriptor in the process.
        @discardableResult
        public func info(
            flavor: BSD.ProcPIDFDInfoFlavor,
            buffer: inout Data
        ) throws -> Int32 {
            try buffer.withUnsafeMutableBytes {
                try self.info(flavor: flavor, bufferPointer: $0)
            }
        }

        /// Gets information about a file descriptor in the process and return it as a specific type.
        @discardableResult
        public func info<DataType>(
            flavor: BSD.ProcPIDFDInfoFlavor,
            returnAs type: DataType.Type = DataType.self
        ) throws -> DataType {
            var buffer = Data(repeating: 0, count: MemoryLayout<DataType>.size)
            try self.info(flavor: flavor, buffer: &buffer)
            return buffer.withUnsafeBytes {
                $0.load(as: DataType.self)
            }
        }

        /// Gets information about a file descriptor in the process and return it as an array of a specific type.
        @discardableResult
        public func info<DataType>(
            flavor: BSD.ProcPIDFDInfoFlavor,
            returnAs type: DataType.Type = DataType.self,
            count: Int
        ) throws -> [DataType] {
            let bufferPointer = UnsafeMutableBufferPointer<DataType>
                .allocate(capacity: count)
            defer { bufferPointer.deallocate() }
            let rawBufferPointer = UnsafeMutableRawBufferPointer(bufferPointer)
            let returnedBufferSize = try self.info(flavor: flavor, bufferPointer: rawBufferPointer)
            return Array(
                rawBufferPointer
                    .prefix(Int(returnedBufferSize))
                    .assumingMemoryBound(to: DataType.self)
            )
        }

        // MARK: - Getters

        // MARK: - Public Flavor Getters

        public var vnodeInfo: vnode_fdinfo {
            get throws { try self.info(flavor: .vnodeInfo) }
        }

        public var vnodePathInfo: vnode_fdinfowithpath {
            get throws { try self.info(flavor: .vnodePathInfo) }
        }

        public var socketInfo: socket_fdinfo {
            get throws { try self.info(flavor: .socketInfo) }
        }

        public var posixSemaphoreInfo: psem_fdinfo {
            get throws { try self.info(flavor: .posixSemaphoreInfo) }
        }

        public var posixSharedMemoryInfo: pshm_fdinfo {
            get throws { try self.info(flavor: .posixSharedMemoryInfo) }
        }

        public var pipeInfo: pipe_fdinfo {
            get throws { try self.info(flavor: .pipeInfo) }
        }

        public var kqueueInfo: kqueue_fdinfo {
            get throws { try self.info(flavor: .kqueueInfo) }
        }

        public var appleTalkInfo: appletalk_fdinfo {
            get throws { try self.info(flavor: .appleTalkInfo) }
        }

        public var channelInfo: channel_fdinfo {
            get throws { try self.info(flavor: .channelInfo) }
        }

        // MARK: - Private Flavor Getters

        public var kqueueExtInfo: [kevent_extinfo] {
            get throws { try self.info(flavor: .kqueueExtInfo) }
        }
    }
}

extension BSD.Proc {
    /// Represents a file descriptor in the process.
    public func fd(_ fd: Int32) -> BSD.ProcPIDFD {
        return BSD.ProcPIDFD(pid: self.pid, fd: fd)
    }
}
