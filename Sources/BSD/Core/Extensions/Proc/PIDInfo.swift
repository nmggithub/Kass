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

        /// All known PID info flavors.
        public static let allCases: [Self] = [
            // Public flavors
            .listFDs, .taskAllInfo, .bsdInfo, .taskInfo, .threadInfo, .listThreads, .regionInfo,
            .regionPathInfo, .vnodePathInfo, .threadPathInfo, .path, .workQueueInfo,
            .shortBSDInfo, .listFileports, .threadID64Info,
            // Private flavors
            .pidUniqueIdentifier, .bsdInfoWithUniqueIdentifier, .archInfo, .coalitionInfo,
            .noteExit, .regionPathInfo2, .regionPathInfo3, .exitReason, .exitReasonBasic,
            .listDynamicQueues, .listThreadIDs, .vmRTFaultInfo, .platform, .regionPath,
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

        public static let vmRTFaultInfo = Self(
            name: "vmRTFaultInfo", rawValue: PROC_PIDVMRTFAULTINFO
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
}

extension BSD.Proc {
    /// Helper functions for getting information about a process.
    public struct PIDInfo: Namespace {
        /// Get information about a process.
        @discardableResult
        public static func call(
            forPID pid: pid_t,
            flavor: BSD.ProcPIDInfoFlavor,
            // We default to 0 to indicate "no value" for flavors that don't use the argument.
            arg: UInt64 = 0,
            bufferPointer: UnsafeMutableRawBufferPointer
        ) throws -> Int32 {
            return try BSD.syscall(
                proc_pidinfo(
                    pid, flavor.rawValue, arg,
                    bufferPointer.baseAddress, Int32(bufferPointer.count)
                )
            )
        }

        /// Get information about a process.
        @discardableResult
        public static func call(
            forPID pid: pid_t,
            flavor: BSD.ProcPIDInfoFlavor,
            // We default to 0 to indicate "no value" for flavors that don't use the argument.
            arg: UInt64 = 0,
            buffer: inout Data
        ) throws -> Int32 {
            try buffer.withUnsafeMutableBytes {
                try self.call(forPID: pid, flavor: flavor, arg: arg, bufferPointer: $0)
            }
        }

        // Get information about a process and return it as a specific type.
        public static func call<DataType>(
            forPID pid: pid_t,
            flavor: BSD.ProcPIDInfoFlavor,
            // We default to 0 to indicate "no value" for flavors that don't use the argument.
            arg: UInt64 = 0,
            returnAs type: DataType.Type = DataType.self
        ) throws -> DataType {
            var buffer = Data(repeating: 0, count: MemoryLayout<DataType>.size)
            try call(forPID: pid, flavor: flavor, arg: arg, buffer: &buffer)
            return buffer.withUnsafeBytes {
                $0.load(as: DataType.self)
            }
        }

        // Get information about a process and return it as an array of a specific type.
        public static func call<DataType>(
            forPID pid: pid_t,
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
            let returnedBufferSize = try call(
                forPID: pid, flavor: flavor, arg: arg,
                bufferPointer: rawBufferPointer
            )
            return Array(
                rawBufferPointer
                    .prefix(Int(returnedBufferSize))
                    .assumingMemoryBound(to: DataType.self)
            )
        }

        // MARK: - Public Flavor Getters

        // List all file descriptors for a process.
        public static func listFDs(forPID pid: pid_t) throws -> [proc_fdinfo] {
            let maxFDsPerProc = try BSD.sysctl("kern.maxfilesperproc")
                .withUnsafeBytes { $0.load(as: Int32.self) }
            return try call(forPID: pid, flavor: .listFDs, count: Int(maxFDsPerProc))
        }

        // Get all information about the task for a process.
        public static func taskAllInfo(forPID pid: pid_t) throws -> proc_taskallinfo {
            try call(forPID: pid, flavor: .taskAllInfo)
        }

        // Get BSD information about a process.
        public static func bsdInfo(forPID pid: pid_t) throws -> proc_bsdinfo {
            try call(forPID: pid, flavor: .bsdInfo)
        }

        /// Get information about a task for a process.
        public static func taskInfo(forPID pid: pid_t) throws -> proc_taskinfo {
            try call(forPID: pid, flavor: .taskInfo)
        }

        /// Get information about a thread for a process.
        /// - Note: The `tsdAddress` parameter is a pointer to the thread-specific data (TSD) for the thread. These
        /// addresses can be iterated over using `listThreads(forPID:)`.
        // The addresses returned by `listThreads(forPID:)` are, more specifically, each value of a pointer called
        // `cthread_self in the thread structs. However, in practice, these are set and used as the TSD pointers.
        public static func threadInfo(forPID pid: pid_t, tsdAddress: UnsafeRawPointer)
            throws -> proc_threadinfo
        {
            let tsdAddressAsUInt64 = UInt64(UInt(bitPattern: tsdAddress))
            return try call(forPID: pid, flavor: .threadInfo, arg: tsdAddressAsUInt64)
        }

        /// List the TSD addresses for all threads in a process.
        public static func listThreads(forPID pid: pid_t) throws -> [UnsafeRawPointer] {
            // The name is a bit vague, but this is the maximum number of threads for a task (and BSD
            // processes map onto Mach tasks), so it's also the maximum thread count for processes.
            let maxThreadsPerProc = try BSD.sysctl("kern.num_taskthreads")
                .withUnsafeBytes { $0.load(as: Int32.self) }
            let addresses: [UInt64] = try call(
                forPID: pid, flavor: .listThreads,
                count: Int(maxThreadsPerProc)
            )
            return addresses.map { UnsafeRawPointer(bitPattern: Int($0))! }
        }

        /// Get information about a region in a process.
        public static func regionInfo(forPID pid: pid_t, region: UInt64) throws -> proc_regioninfo {
            try call(forPID: pid, flavor: .regionInfo, arg: region)
        }

        /// Get information about a region in a process, including the path.
        public static func regionPathInfo(forPID pid: pid_t, region: UInt64)
            throws -> proc_regionwithpathinfo
        {
            try call(forPID: pid, flavor: .regionPathInfo, arg: region)
        }

        /// Get information about the vnode for a process.
        public static func vnodePathInfo(forPID pid: pid_t) throws -> proc_vnodepathinfo {
            try call(forPID: pid, flavor: .vnodePathInfo)
        }

        /// Get information about a thread in a process, including the path.
        public static func threadPathInfo(forPID pid: pid_t, arg: UInt64)
            throws -> proc_threadwithpathinfo
        {
            try call(forPID: pid, flavor: .threadPathInfo, arg: arg)
        }

        /// Get the path of the executable for a process.
        public static func getPath(forPID pid: pid_t) throws -> String? {
            var pathBuffer = Data(repeating: 0, count: Int(MAXPATHLEN))
            try call(forPID: pid, flavor: .path, buffer: &pathBuffer)
            return pathBuffer.withUnsafeBytes {
                (bufferPointer) -> String? in
                guard let stringPointer = bufferPointer.baseAddress
                else { return nil }
                return String(
                    cString: stringPointer.bindMemory(to: CChar.self, capacity: pathBuffer.count)
                )
            }
        }

        /// Get information about the work queues for a process.
        public static func workQueueInfo(forPID pid: pid_t) throws -> proc_workqueueinfo {
            try call(forPID: pid, flavor: .workQueueInfo)
        }

        /// Get short BSD information about a process.
        public static func shortBSDInfo(forPID pid: pid_t) throws -> proc_bsdshortinfo {
            try call(forPID: pid, flavor: .shortBSDInfo)
        }

        /// List all file ports for a process.
        public static func listFileports(forPID pid: pid_t) throws -> [proc_fileportinfo] {
            let maxFileportsPerProc = try BSD.sysctl("kern.maxfilesperproc")
                .withUnsafeBytes { $0.load(as: Int32.self) }
            return try call(forPID: pid, flavor: .listFileports, count: Int(maxFileportsPerProc))
        }

        /// Get information about a thread in a process.
        public static func threadID64Info(forPID pid: pid_t, threadID: UInt64)
            throws -> proc_threadinfo
        {
            try call(forPID: pid, flavor: .threadID64Info, arg: threadID)
        }

        // MARK: - Private Flavor Getters

        /// Get unique identifier information for a process.
        public static func uniqueIdentifier(forPID pid: pid_t)
            throws -> proc_uniqidentifierinfo
        {
            try call(forPID: pid, flavor: .pidUniqueIdentifier)
        }

        /// Get BSD information for a process, along with the unique identifier information.
        public static func bsdInfoWithUniqueIdentifier(forPID pid: pid_t)
            throws -> proc_bsdinfowithuniqid
        {
            try call(forPID: pid, flavor: .bsdInfoWithUniqueIdentifier)
        }

        /// Get architecture information for a process.
        public static func archInfo(forPID pid: pid_t) throws -> proc_archinfo {
            try call(forPID: pid, flavor: .archInfo)
        }

        /// Get coalition information for a process.
        public static func coalitionInfo(forPID pid: pid_t) throws -> proc_pidcoalitioninfo {
            try call(forPID: pid, flavor: .coalitionInfo)
        }

        /// Get exit notification information for a process.
        public static func noteExit(forPID pid: pid_t) throws -> UInt32 {
            try call(forPID: pid, flavor: .noteExit)
        }

        /// Get region information for a process, including the path.
        public static func regionPathInfo2(forPID pid: pid_t, region: UInt64)
            throws -> proc_regionwithpathinfo
        {
            try call(forPID: pid, flavor: .regionPathInfo2, arg: region)
        }

        /// Get region information for a process, including the path.
        public static func regionPathInfo3(forPID pid: pid_t, region: UInt64)
            throws -> proc_regionwithpathinfo
        {
            try call(forPID: pid, flavor: .regionPathInfo3, arg: region)
        }

        /// Get exit reason information for a process.
        public static func exitReason(forPID pid: pid_t) throws -> proc_exitreasoninfo {
            try call(forPID: pid, flavor: .exitReason)
        }

        /// Get basic exit reason information for a process.
        public static func exitReasonBasic(forPID pid: pid_t) throws -> proc_exitreasonbasicinfo {
            try call(forPID: pid, flavor: .exitReasonBasic)
        }

        /// List the user pointers for a process.
        public static func listUserPointers(forPID pid: pid_t) throws -> [UInt64] {
            // The largest buffer size is `Int32.max`, so the maximum count is that
            // divided by the size of a user pointer.
            let maxUserPointersPerProc = Int(Int32.max) / MemoryLayout<UInt64>.size
            return try call(forPID: pid, flavor: .listUserPointers, count: maxUserPointersPerProc)
        }

        /// List the dynamic queues for a process.
        public static func listDynamicQueues(forPID pid: pid_t) throws -> [kqueue_id_t] {
            // The largest buffer size is `Int32.max`, so the maximum count is that
            // divided by the size of a queue ID.
            let maxDynamicQueuesPerProc = Int(Int32.max) / MemoryLayout<UInt64>.size
            return try call(
                forPID: pid, flavor: .listDynamicQueues, count: Int(maxDynamicQueuesPerProc))
        }

        /// List the thread IDs for a process.
        public static func listThreadIDs(forPID pid: pid_t) throws -> [UInt64] {
            // The name is a bit vague, but this is the maximum number of threads for a task (and BSD
            // processes map onto Mach tasks), so it's also the maximum thread count for processes.
            let maxThreadsPerProc = try BSD.sysctl("kern.num_taskthreads")
                .withUnsafeBytes { $0.load(as: Int32.self) }
            return try call(forPID: pid, flavor: .listThreadIDs, count: Int(maxThreadsPerProc))
        }

        public static func vmRTFaultInfo(forPID pid: pid_t) throws -> [vm_rtfault_record_t] {
            // The largest buffer size is `Int32.max`, so the maximum count is that
            // divided by the size of a fault record.
            let maxDynamicQueuesPerProc = Int(Int32.max) / MemoryLayout<vm_rtfault_record_t>.size
            return try call(forPID: pid, flavor: .vmRTFaultInfo, count: maxDynamicQueuesPerProc)
        }

        /// Get the platform for a process.
        public static func getPlatform(forPID pid: pid_t) throws -> UInt32 {
            try call(forPID: pid, flavor: .platform)
        }

        /// Get the path of a region in a process.
        public static func regionPath(forPID pid: pid_t, region: UInt64) throws -> proc_regionpath {
            try call(forPID: pid, flavor: .regionPath, arg: region)
        }

        /// Get information about the IPC table for a process.
        public static func ipcTableInfo(forPID pid: pid_t) throws -> proc_ipctableinfo {
            try call(forPID: pid, flavor: .ipcTableInfo)
        }

        /// Get scheduling information for a thread in a process.
        public static func threadSchedulingInfo(forPID pid: pid_t, threadID: UInt64)
            throws -> proc_threadinfo
        {
            try call(forPID: pid, flavor: .threadSchedulingInfo, arg: threadID)
        }

        /// Get thread counts for a process.
        public static func threadCounts(forPID pid: pid_t) throws -> proc_threadcounts {
            let numberOfPerformanceLevels = try BSD.sysctl("hw.nperflevels")
                .withUnsafeBytes { $0.load(as: Int32.self) }
            let dataSize =
                MemoryLayout<proc_threadcounts>.size
                + (Int(numberOfPerformanceLevels) * MemoryLayout<proc_threadcounts_data>.size)
            var buffer = Data(repeating: 0, count: dataSize)
            let returnedSize = try call(forPID: pid, flavor: .threadCounts, buffer: &buffer)
            return buffer.prefix(Int(returnedSize)).withUnsafeBytes {
                $0.load(as: proc_threadcounts.self)
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
