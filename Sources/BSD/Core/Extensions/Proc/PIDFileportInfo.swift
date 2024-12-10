import Darwin.POSIX
import Foundation
import KassC.ProcInfoPrivate
import KassHelpers

extension BSD {
    // A flavor of PID fileport info.
    public struct PIDFileportInfoFlavor: KassHelpers.NamedOptionEnum {
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
}

// MARK: - Getters

extension BSD.Proc {

    /// Helper functions for getting information about a fileport in a process.
    public struct PIDFileportInfo: Namespace {
        /// Get information about a fileport in a process.
        @discardableResult
        public static func call(
            forPID pid: pid_t, fileport: BSD.Fileport,
            flavor: BSD.PIDFileportInfoFlavor,
            bufferPointer: UnsafeMutableRawBufferPointer
        ) throws -> Int32 {
            try BSD.syscall(
                proc_pidfileportinfo(
                    pid, fileport.name, flavor.rawValue,
                    bufferPointer.baseAddress, Int32(bufferPointer.count)
                )
            )
        }

        /// Get information about a fileport in a process.
        @discardableResult
        public static func call(
            forPID pid: pid_t, fileport: BSD.Fileport,
            flavor: BSD.PIDFileportInfoFlavor,
            buffer: inout Data
        ) throws -> Int32 {
            try buffer.withUnsafeMutableBytes {
                try self.call(forPID: pid, fileport: fileport, flavor: flavor, bufferPointer: $0)
            }
        }

        /// Get information about a fileport in a process and return it as a specific type.
        @discardableResult
        public static func call<DataType>(
            forPID pid: pid_t, fileport: BSD.Fileport,
            flavor: BSD.PIDFileportInfoFlavor,
            returnAs type: DataType.Type = DataType.self
        ) throws -> DataType {
            var buffer = Data(repeating: 0, count: MemoryLayout<DataType>.size)
            try self.call(forPID: pid, fileport: fileport, flavor: flavor, buffer: &buffer)
            return buffer.withUnsafeBytes {
                $0.load(as: DataType.self)
            }
        }

        /// Get information about a fileport in a process and return it as an array of a specific type.
        @discardableResult
        public static func call<DataType>(
            forPID pid: pid_t, fileport: BSD.Fileport,
            flavor: BSD.PIDFileportInfoFlavor,
            returnAs type: DataType.Type = DataType.self,
            count: Int
        ) throws -> [DataType] {
            let bufferPointer = UnsafeMutableBufferPointer<DataType>
                .allocate(capacity: count)
            defer { bufferPointer.deallocate() }
            let rawBufferPointer = UnsafeMutableRawBufferPointer(bufferPointer)
            let returnedBufferSize = try call(
                forPID: pid, fileport: fileport, flavor: flavor,
                bufferPointer: rawBufferPointer
            )
            return Array(
                rawBufferPointer
                    .prefix(Int(returnedBufferSize))
                    .assumingMemoryBound(to: DataType.self)
            )
        }

        // MARK: - Public Flavor Getters

        public static func vnodePathInfo(
            forPID pid: pid_t, fileport: BSD.Fileport
        ) throws -> vnode_fdinfowithpath {
            try call(forPID: pid, fileport: fileport, flavor: .vnodePathInfo)
        }

        public static func socketInfo(
            forPID pid: pid_t, fileport: BSD.Fileport
        ) throws -> socket_fdinfo {
            try call(forPID: pid, fileport: fileport, flavor: .socketInfo)
        }

        public static func posixSharedMemoryInfo(
            forPID pid: pid_t, fileport: BSD.Fileport
        ) throws -> pshm_fdinfo {
            try call(forPID: pid, fileport: fileport, flavor: .posixSharedMemoryInfo)
        }

        public static func pipeInfo(
            forPID pid: pid_t, fileport: BSD.Fileport
        ) throws -> pipe_fdinfo {
            try call(forPID: pid, fileport: fileport, flavor: .pipeInfo)
        }
    }
}
