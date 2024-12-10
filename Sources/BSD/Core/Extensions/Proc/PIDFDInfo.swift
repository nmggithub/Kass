import Darwin.POSIX
import Foundation
import KassC.ProcInfoPrivate
import KassHelpers

extension BSD {
    // A flavor of PID file descriptor info.
    public struct PIDFDInfoFlavor: KassHelpers.NamedOptionEnum {
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
}

// MARK: - Getters

extension BSD.Proc {

    /// Helper functions for getting information about a file descriptor in a process.
    public struct PIDFDInfo: Namespace {
        /// Get information about a file descriptor in a process.
        @discardableResult
        public static func call(
            forPID pid: pid_t, fd: Int32,
            flavor: BSD.PIDFDInfoFlavor,
            bufferPointer: UnsafeMutableRawBufferPointer
        ) throws -> Int32 {
            try BSD.syscall(
                proc_pidfdinfo(
                    pid, fd, flavor.rawValue,
                    bufferPointer.baseAddress, Int32(bufferPointer.count)
                )
            )
        }

        /// Get information about a file descriptor in a process.
        @discardableResult
        public static func call(
            forPID pid: pid_t, fd: Int32,
            flavor: BSD.PIDFDInfoFlavor,
            buffer: inout Data
        ) throws -> Int32 {
            try buffer.withUnsafeMutableBytes {
                try self.call(forPID: pid, fd: fd, flavor: flavor, bufferPointer: $0)
            }
        }

        /// Get information about a file descriptor in a process and return it as a specific type.
        @discardableResult
        public static func call<DataType>(
            forPID pid: pid_t, fd: Int32,
            flavor: BSD.PIDFDInfoFlavor,
            returnAs type: DataType.Type = DataType.self
        ) throws -> DataType {
            var buffer = Data(repeating: 0, count: MemoryLayout<DataType>.size)
            try self.call(forPID: pid, fd: fd, flavor: flavor, buffer: &buffer)
            return buffer.withUnsafeBytes {
                $0.load(as: DataType.self)
            }
        }

        /// Get information about a file descriptor in a process and return it as an array of a specific type.
        @discardableResult
        public static func call<DataType>(
            forPID pid: pid_t, fd: Int32,
            flavor: BSD.PIDFDInfoFlavor,
            returnAs type: DataType.Type = DataType.self,
            count: Int
        ) throws -> [DataType] {
            let bufferPointer = UnsafeMutableBufferPointer<DataType>
                .allocate(capacity: count)
            defer { bufferPointer.deallocate() }
            let rawBufferPointer = UnsafeMutableRawBufferPointer(bufferPointer)
            let returnedBufferSize = try call(
                forPID: pid, fd: fd, flavor: flavor,
                bufferPointer: rawBufferPointer
            )
            return Array(
                rawBufferPointer
                    .prefix(Int(returnedBufferSize))
                    .assumingMemoryBound(to: DataType.self)
            )
        }

        // MARK: - Public Flavor Getters

        public static func vnodeInfo(
            forPID pid: pid_t, fd: Int32
        ) throws -> vnode_fdinfo {
            try call(forPID: pid, fd: fd, flavor: .vnodeInfo)
        }

        public static func vnodePathInfo(
            forPID pid: pid_t, fd: Int32
        ) throws -> vnode_fdinfowithpath {
            try call(forPID: pid, fd: fd, flavor: .vnodePathInfo)
        }

        public static func socketInfo(
            forPID pid: pid_t, fd: Int32
        ) throws -> socket_fdinfo {
            try call(forPID: pid, fd: fd, flavor: .socketInfo)
        }

        public static func posixSemaphoreInfo(
            forPID pid: pid_t, fd: Int32
        ) throws -> psem_fdinfo {
            try call(forPID: pid, fd: fd, flavor: .posixSemaphoreInfo)
        }

        public static func posixSharedMemoryInfo(
            forPID pid: pid_t, fd: Int32
        ) throws -> pshm_fdinfo {
            try call(forPID: pid, fd: fd, flavor: .posixSharedMemoryInfo)
        }

        public static func pipeInfo(
            forPID pid: pid_t, fd: Int32
        ) throws -> pipe_fdinfo {
            try call(forPID: pid, fd: fd, flavor: .pipeInfo)
        }

        public static func kqueueInfo(
            forPID pid: pid_t, fd: Int32
        ) throws -> kqueue_fdinfo {
            try call(forPID: pid, fd: fd, flavor: .kqueueInfo)
        }

        public static func appleTalkInfo(
            forPID pid: pid_t, fd: Int32
        ) throws -> appletalk_fdinfo {
            try call(forPID: pid, fd: fd, flavor: .appleTalkInfo)
        }

        public static func channelInfo(
            forPID pid: pid_t, fd: Int32
        ) throws -> channel_fdinfo {
            try call(forPID: pid, fd: fd, flavor: .channelInfo)
        }

        // MARK: - Private Flavor Getters

        public static func kqueueExtInfo(
            forPID pid: pid_t, fd: Int32
        ) throws -> [kevent_extinfo] {
            try call(forPID: pid, fd: fd, flavor: .kqueueExtInfo)
        }
    }
}
