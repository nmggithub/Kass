import Darwin.POSIX
import Foundation
import KassC.ProcInfoPrivate
import KassHelpers

extension BSD {
    // A flavor of PID info.
    public struct ProcPIDInfoFlavor: KassHelpers.NamedOptionEnum {
        /// The name of the flavor, if it can be determined.
        public var name: String?

        /// Represents a PID info flavor with an optional name.
        public init(name: String?, rawValue: Int32) {
            self.name = name
            self.rawValue = rawValue
        }

        /// The raw value of the flavor.
        public let rawValue: Int32
        public static let allCases: [Self] = [
            // Public flavors
            .listFDs, .taskAllInfo, .bsdInfo, .taskInfo, .threadInfo, .listThreads, .regionInfo,
            .regionPathInfo, .vnodePathInfo, .threadPathInfo, .path, .workQueueInfo,
            .shortBSDInfo, .listFileports, .threadID64Info,
            // Private flavors
            .pidUniqueIdentifier, .bsdInfoWithUniqueIdentifier, .archInfo, .coalitionInfo,
            .noteExit, .regionPathInfo2, .regionPathInfo3, .exitReason, .exitReasonBasic,
            .listDynamicQueues, .listThreadIDs, .vmRealtimeFaultInfo, .platform, .regionPath,
            .ipcTableInfo, .threadSchedulingInfo, .threadCounts,
        ]

        // MARK: - Public Flavors

        public static let listFDs = Self(
            name: "listFDs", rawValue: PROC_PIDLISTFDS
        )

        public static let taskAllInfo = Self(
            name: "allInfo", rawValue: PROC_PIDTASKALLINFO
        )

        public static let bsdInfo = Self(
            name: "bsdInfo", rawValue: PROC_PIDTASKINFO
        )

        public static let taskInfo = Self(
            name: "taskInfo", rawValue: PROC_PIDTASKINFO
        )

        public static let threadInfo = Self(
            name: "threadInfo", rawValue: PROC_PIDTHREADINFO
        )

        public static let listThreads = Self(
            name: "listThreads", rawValue: PROC_PIDLISTTHREADS
        )

        public static let regionInfo = Self(
            name: "regionInfo", rawValue: PROC_PIDREGIONINFO
        )

        public static let regionPathInfo = Self(
            name: "regionPathInfo", rawValue: PROC_PIDREGIONPATHINFO
        )

        public static let vnodePathInfo = Self(
            name: "vnodePathInfo", rawValue: PROC_PIDVNODEPATHINFO
        )

        public static let threadPathInfo = Self(
            name: "threadPathInfo", rawValue: PROC_PIDTHREADPATHINFO
        )

        public static let path = Self(
            name: "path", rawValue: PROC_PIDPATHINFO
        )

        public static let workQueueInfo = Self(
            name: "workQueueInfo", rawValue: PROC_PIDWORKQUEUEINFO
        )

        public static let shortBSDInfo = Self(
            name: "shortBSDInfo", rawValue: PROC_PIDT_SHORTBSDINFO
        )

        public static let listFileports = Self(
            name: "listFileports", rawValue: PROC_PIDLISTFILEPORTS
        )

        public static let threadID64Info = Self(
            name: "threadID64Info", rawValue: PROC_PIDTHREADID64INFO
        )

        // MARK: - Private Flavors

        public static let pidUniqueIdentifier = Self(
            name: "pidUniqueIdentifier", rawValue: PROC_PIDUNIQIDENTIFIERINFO
        )

        public static let bsdInfoWithUniqueIdentifier = Self(
            name: "bsdInfoWithUniqueIdentifier", rawValue: PROC_PIDT_BSDINFOWITHUNIQID
        )

        public static let archInfo = Self(
            name: "archInfo", rawValue: PROC_PIDARCHINFO
        )

        public static let coalitionInfo = Self(
            name: "coalitionInfo", rawValue: PROC_PIDCOALITIONINFO
        )

        public static let noteExit = Self(
            name: "noteExit", rawValue: PROC_PIDNOTEEXIT
        )

        public static let regionPathInfo2 = Self(
            name: "regionPathInfo2", rawValue: PROC_PIDREGIONPATHINFO2
        )

        public static let regionPathInfo3 = Self(
            name: "regionPathInfo3", rawValue: PROC_PIDREGIONPATHINFO3
        )

        public static let exitReason = Self(
            name: "exitReason", rawValue: PROC_PIDEXITREASONINFO
        )

        public static let exitReasonBasic = Self(
            name: "exitReasonBasic", rawValue: PROC_PIDEXITREASONBASICINFO
        )

        public static let listUserPointers = Self(
            name: "listUserPointers", rawValue: PROC_PIDLISTUPTRS
        )

        public static let listDynamicQueues = Self(
            name: "listDynamicQueues", rawValue: PROC_PIDLISTDYNKQUEUES
        )

        public static let listThreadIDs = Self(
            name: "listThreadIDs", rawValue: PROC_PIDLISTTHREADIDS
        )

        public static let vmRealtimeFaultInfo = Self(
            name: "vmRealtimeFaultInfo", rawValue: PROC_PIDVMRTFAULTINFO
        )

        public static let platform = Self(
            name: "platform", rawValue: PROC_PIDPLATFORMINFO
        )

        public static let regionPath = Self(
            name: "regionPath", rawValue: PROC_PIDREGIONPATH
        )

        public static let ipcTableInfo = Self(
            name: "ipcTableInfo", rawValue: PROC_PIDIPCTABLEINFO
        )

        public static let threadSchedulingInfo = Self(
            name: "threadSchedulingInfo", rawValue: PROC_PIDTHREADSCHEDINFO
        )

        public static let threadCounts = Self(
            name: "threadCounts", rawValue: PROC_PIDTHREADCOUNTS
        )
    }

    /// A process represented by a PID.
    public struct Proc {
        // The PID of the process.
        public let pid: pid_t

        /// Represents a process with a PID.
        public init(pid: pid_t) { self.pid = pid }

        /// Gets information about the process.
        @discardableResult
        public func info(
            flavor: BSD.ProcPIDInfoFlavor,
            arg: UInt64 = 0,
            bufferPointer: UnsafeMutableRawBufferPointer
        ) throws -> Int32 {
            return try BSD.syscall(
                proc_pidinfo(
                    self.pid, flavor.rawValue, arg,
                    bufferPointer.baseAddress, Int32(bufferPointer.count)
                )
            )
        }

        /// Gets information about the process.
        @discardableResult
        public func info(
            flavor: BSD.ProcPIDInfoFlavor,
            arg: UInt64 = 0,
            buffer: inout Data
        ) throws -> Int32 {
            try buffer.withUnsafeMutableBytes {
                try self.info(flavor: flavor, arg: arg, bufferPointer: $0)
            }
        }

        /// Gets information about a process and return it as a specific type.
        public func info<DataType>(
            flavor: BSD.ProcPIDInfoFlavor,
            arg: UInt64 = 0,
            returnAs type: DataType.Type = DataType.self
        ) throws -> DataType {
            var buffer = Data(repeating: 0, count: MemoryLayout<DataType>.size)
            try self.info(flavor: flavor, arg: arg, buffer: &buffer)
            return buffer.withUnsafeBytes { $0.load(as: DataType.self) }
        }

        /// Gets information about a process and return it as an array of a specific type.
        public func info<DataType>(
            flavor: BSD.ProcPIDInfoFlavor,
            // We default to 0 to indicate "no value" for flavors that don't use the argument.
            arg: UInt64 = 0,
            returnAsArrayOf type: DataType.Type = DataType.self,
            count: Int
        ) throws -> [DataType] {
            let bufferPointer = UnsafeMutableBufferPointer<DataType>
                .allocate(capacity: count)
            defer { bufferPointer.deallocate() }
            let rawBufferPointer = UnsafeMutableRawBufferPointer(bufferPointer)
            let returnedBufferSize = try info(
                flavor: flavor, arg: arg,
                bufferPointer: rawBufferPointer
            )
            return Array(
                rawBufferPointer
                    .prefix(Int(returnedBufferSize))
                    .assumingMemoryBound(to: DataType.self)
            )
        }

        // MARK: - Public Flavor Getters

        /// Information about all file descriptors for the process.
        public var fileDescriptors: [proc_fdinfo] {
            get throws {
                let maxFDsPerProc = try BSD.sysctl("kern.maxfilesperproc")
                    .withUnsafeBytes { $0.load(as: Int32.self) }
                return try self.info(flavor: .listFDs, count: Int(maxFDsPerProc))
            }
        }

        /// All information about the task for the process.
        public var taskAllInfo: proc_taskallinfo {
            get throws { try self.info(flavor: .taskAllInfo) }
        }

        /// BSD information about the process.
        public var bsdInfo: proc_bsdinfo {
            get throws { try self.info(flavor: .bsdInfo) }
        }

        /// Information about a task for thr process.
        public var taskInfo: proc_taskinfo {
            get throws { try self.info(flavor: .taskInfo) }
        }

        /// Gets information about a thread for the process.
        /// - Note: The `tsdAddress` parameter is a pointer to the thread-specific data (TSD) for the thread. These
        /// addresses can be retrieved using ```threadTSDAddresses```.
        public func threadInfo(tsdAddress: UnsafeRawPointer) throws -> [UnsafeRawPointer] {
            let tsdAddressAsUInt64 = UInt64(UInt(bitPattern: tsdAddress))
            return try self.info(flavor: .threadInfo, arg: tsdAddressAsUInt64)
        }

        /// The list of thread-specific data (TSD) addresses for all threads in the process.
        /// - Note: The addresses returned by this function are, more specifically, the values of the pointer
        /// field `cthread_self` for each of the thread structs in the kernel. In practice though, that field
        /// is used by the kernel to store the address of the thread-specific data (TSD).
        public var tsdAddresses: [UnsafeRawPointer] {
            get throws {
                // The name is a bit vague, but this is the maximum number of threads for a task (and BSD}
                // processes map onto Mach tasks), so it's also the maximum thread count for processes.
                let maxThreadsPerProc = try BSD.sysctl("kern.num_taskthreads")
                    .withUnsafeBytes { $0.load(as: Int32.self) }
                let addresses: [UInt64] = try self.info(
                    flavor: .listThreads,
                    count: Int(maxThreadsPerProc)
                )
                return addresses.map { UnsafeRawPointer(bitPattern: Int($0))! }
            }
        }

        /// Gets information about a region in the process.
        public func regionInfo(address: UnsafeRawPointer) throws -> proc_regioninfo {
            try self.info(flavor: .regionInfo, arg: UInt64(UInt(bitPattern: address)))
        }

        /// Gets information about a region in a process, including the path.
        public func regionPathInfo(address: UnsafeRawPointer) throws -> proc_regionwithpathinfo {
            try self.info(flavor: .regionPathInfo, arg: UInt64(UInt(bitPattern: address)))
        }

        /// Information about the vnode for the process.
        public var vnodePathInfo: proc_vnodepathinfo {
            get throws { try self.info(flavor: .vnodePathInfo) }
        }

        /// Gets information about a thread in a process, including the path.
        public func threadPathInfo(tsdAddress: UnsafeRawPointer) throws -> proc_threadwithpathinfo {
            try self.info(flavor: .threadPathInfo, arg: UInt64(UInt(bitPattern: tsdAddress)))
        }

        /// The path of the executable for the process.
        public var path: String? {
            get throws {
                var pathBuffer = Data(repeating: 0, count: Int(MAXPATHLEN))
                try self.info(flavor: .path, buffer: &pathBuffer)
                return pathBuffer.withUnsafeBytes {
                    (bufferPointer) -> String? in
                    guard let stringPointer = bufferPointer.baseAddress
                    else { return nil }
                    return String(
                        cString: stringPointer.bindMemory(
                            to: CChar.self, capacity: pathBuffer.count)
                    )
                }
            }
        }

        /// Information about the work queues for the process.
        public var workQueueInfo: proc_workqueueinfo {
            get throws { try self.info(flavor: .workQueueInfo) }
        }

        /// Short BSD information about the process.
        public var shortBSDInfo: proc_bsdshortinfo {
            get throws { try self.info(flavor: .shortBSDInfo) }
        }

        /// Information about all file ports for the process.
        public var fileports: [proc_fileportinfo] {
            get throws {
                let maxFileportsPerProc = try BSD.sysctl("kern.maxfilesperproc")
                    .withUnsafeBytes { $0.load(as: Int32.self) }
                return try self.info(flavor: .listFileports, count: Int(maxFileportsPerProc))
            }
        }

        /// Gets information about a thread in the process.
        public func threadInfo(threadID: UInt64) throws -> proc_threadinfo {
            try self.info(flavor: .threadInfo, arg: threadID)
        }

        // MARK: - Private Flavor Getters

        /// Unique identifier information for the process.
        public var uniqueIdentifier: proc_uniqidentifierinfo {
            get throws {
                try self.info(flavor: .pidUniqueIdentifier)
            }
        }

        /// BSD information for a process, along with the unique identifier information.
        public var bsdInfoWithUniqueIdentifier: proc_bsdinfowithuniqid
        {
            get throws {
                try self.info(flavor: .bsdInfoWithUniqueIdentifier)
            }
        }

        /// Gets architecture information for the process.
        public var archInfo: proc_archinfo {
            get throws { try self.info(flavor: .archInfo) }
        }

        /// Gets coalition information for the process.
        public var coalitionInfo: proc_pidcoalitioninfo {
            get throws { try self.info(flavor: .coalitionInfo) }
        }

        /// Gets exit information for the process.
        public var noteExit: UInt32 {
            get throws { try self.info(flavor: .noteExit) }
        }

        /// Gets region information for a process, including the path.
        public func regionPathInfo2(address: UnsafeRawPointer) throws
            -> proc_regionwithpathinfo
        {
            try self.info(flavor: .regionPathInfo2, arg: UInt64(UInt(bitPattern: address)))
        }

        /// Gets region information for a process, including the path.
        public func regionPathInfo3(address: UnsafeRawPointer) throws
            -> proc_regionwithpathinfo
        {
            try self.info(flavor: .regionPathInfo3, arg: UInt64(UInt(bitPattern: address)))
        }

        /// Exit reason information for the process.
        public var exitReason: proc_exitreasoninfo {
            get throws { try self.info(flavor: .exitReason) }
        }

        /// Basic exit reason information for the process.
        public var exitReasonBasic: proc_exitreasonbasicinfo {
            get throws { try self.info(flavor: .exitReasonBasic) }
        }

        /// The list of user pointers for the process.
        public var userPointers: [UnsafeRawPointer?] {
            get throws {  // The largest buffer size is `Int32.max`, so the maximum count is that
                // divided by the size of a user pointer.
                let maxUserPointersPerProc = Int(Int32.max) / MemoryLayout<UInt64>.size
                let rawPointers: [UInt64] = try self.info(
                    flavor: .listUserPointers, count: maxUserPointersPerProc)
                return rawPointers.map { UnsafeRawPointer(bitPattern: Int($0)) }
            }
        }

        /// The list of dynamic queues for the process.
        public var dynamicQueues: [kqueue_id_t] {
            get throws {  // The largest buffer size is `Int32.max`, so the maximum count is that
                // divided by the size of a queue ID.
                let maxDynamicQueuesPerProc = Int(Int32.max) / MemoryLayout<UInt64>.size
                return try self.info(
                    flavor: .listDynamicQueues, count: Int(maxDynamicQueuesPerProc))
            }
        }

        /// The list of thread IDs for the process.
        public var threadIDs: [UInt64] {
            get throws {  // The name is a bit vague, but this is the maximum number of threads for a task (and BSD
                // processes map onto Mach tasks), so it's also the maximum thread count for processes.
                let maxThreadsPerProc = try BSD.sysctl("kern.num_taskthreads")
                    .withUnsafeBytes { $0.load(as: Int32.self) }
                return try self.info(flavor: .listThreadIDs, count: Int(maxThreadsPerProc))
            }
        }

        /// Fault records for threads in the process that use real-time scheduling.
        public var vmRealtimeFaultRecords: [vm_rtfault_record_t] {
            get throws {  // The largest buffer size is `Int32.max`, so the maximum count is that
                // divided by the size of a fault record.
                let maxDynamicQueuesPerProc =
                    Int(Int32.max) / MemoryLayout<vm_rtfault_record_t>.size
                return try self.info(flavor: .vmRealtimeFaultInfo, count: maxDynamicQueuesPerProc)
            }
        }

        /// The platform for the process.
        public var getPlatform: UInt32 {
            get throws { try self.info(flavor: .platform) }
        }

        /// The path of a region in the process.
        public func regionPath(address: UnsafeRawPointer) throws -> proc_regionpath {
            try self.info(flavor: .regionPath, arg: UInt64(UInt(bitPattern: address)))
        }

        /// Information about the IPC table for the process.
        public var ipcTableInfo: proc_ipctableinfo {
            get throws { try self.info(flavor: .ipcTableInfo) }
        }

        /// Scheduling information for a thread in the process.
        public var threadSchedulingInfo: proc_threadschedinfo {
            get throws { try self.info(flavor: .threadSchedulingInfo) }
        }

        /// Thread counts for the process.
        public var threadCounts: proc_threadcounts {
            get throws {
                let numberOfPerformanceLevels = try BSD.sysctl("hw.nperflevels")
                    .withUnsafeBytes { $0.load(as: Int32.self) }
                let dataSize =
                    MemoryLayout<proc_threadcounts>.size
                    + (Int(numberOfPerformanceLevels) * MemoryLayout<proc_threadcounts_data>.size)
                var buffer = Data(repeating: 0, count: dataSize)
                let returnedSize = try self.info(flavor: .threadCounts, buffer: &buffer)
                return buffer.prefix(Int(returnedSize)).withUnsafeBytes {
                    $0.load(as: proc_threadcounts.self)
                }
            }
        }
    }
}

extension proc_threadcounts {
    public var ptc_counts: [proc_threadcounts_data] {
        return withUnsafeBytes(of: self) {
            bufferPointer in
            guard let baseAddress = bufferPointer.baseAddress
            else { return [] }
            // There is a variable array at the end of the struct. Thankfully, it does not contribute
            // to the size, so we can just advance the pointer by the size to get to the start of the
            // array.
            let arrayPointer = UnsafeRawPointer(
                baseAddress.advanced(by: MemoryLayout<proc_threadcounts>.size)
            ).assumingMemoryBound(to: proc_threadcounts_data.self)
            return Array(
                UnsafeBufferPointer(
                    start: arrayPointer,
                    count: Int(self.ptc_len)  // This is probably the count of the array, but it's not clear.
                )
            )
        }
    }
}
