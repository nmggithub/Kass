import Darwin.Mach
import Foundation

extension Mach.Host {
    /// A lock group.
    public struct LockGroup: RawRepresentable {
        public var rawValue: lockgroup_info_t {
            var rawValue = lockgroup_info_t()
            var nameData = name.data(using: .utf8)!
            let remaining = Int(LOCKGROUP_MAX_NAME) - nameData.count
            if remaining > 0 { nameData += Data(repeating: 0, count: remaining) }
            let nameCString = String(
                data: nameData.prefix(Int(LOCKGROUP_MAX_NAME)),
                encoding: .utf8
            )!.cString(using: .utf8)!
            strncpy(&rawValue.lockgroup_name, nameCString, Int(LOCKGROUP_MAX_NAME))
            rawValue.lock_spin_cnt = spinCount
            rawValue.lock_mtx_cnt = mutexCount
            rawValue.lock_rw_cnt = rwCount

            rawValue.lock_spin_held_cnt = spinHeldCount
            rawValue.lock_spin_miss_cnt = spinMissCount
            rawValue.lock_mtx_util_cnt = mutexUtilCount
            rawValue.lock_mtx_held_cnt = mutexHeldCount
            rawValue.lock_mtx_miss_cnt = mutexMissCount
            rawValue.lock_mtx_wait_cnt = mutexWaitCount
            return rawValue
        }
        public init(rawValue: lockgroup_info_t) {
            self.name = withUnsafePointer(to: rawValue.lockgroup_name) {
                pointer in
                pointer.withMemoryRebound(to: CChar.self, capacity: Int(LOCKGROUP_MAX_NAME)) {
                    String(cString: $0)
                }
            }
            self.spinCount = rawValue.lock_spin_cnt
            self.mutexCount = rawValue.lock_mtx_cnt
            self.rwCount = rawValue.lock_rw_cnt

            self.spinHeldCount = rawValue.lock_spin_held_cnt
            self.spinMissCount = rawValue.lock_spin_miss_cnt
            self.mutexUtilCount = rawValue.lock_mtx_util_cnt
            self.mutexHeldCount = rawValue.lock_mtx_held_cnt
            self.mutexMissCount = rawValue.lock_mtx_miss_cnt
            self.mutexWaitCount = rawValue.lock_mtx_wait_cnt
        }
        public let name: String
        public let spinCount: UInt64
        public let mutexCount: UInt64
        public let rwCount: UInt64

        /// - Important: This value is only available on kernels compiled with DTrace support.
        public let spinHeldCount: UInt64
        /// - Important: This value is only available on kernels compiled with DTrace support.
        public let spinMissCount: UInt64
        /// - Important: This value is only available on kernels compiled with DTrace support.
        public let mutexUtilCount: UInt64
        /// - Important: This value is only available on kernels compiled with DTrace support.
        public let mutexHeldCount: UInt64
        /// - Important: This value is only available on kernels compiled with DTrace support.
        public let mutexMissCount: UInt64
        /// - Important: This value is only available on kernels compiled with DTrace support.
        public let mutexWaitCount: UInt64

        // `lockgroup_info_t` has other fields, but they appear to be unused, so they are not included here.
    }
    /// The lock groups in the host.
    public var lockGroups: [LockGroup] {
        get throws {
            var lockGroupInfo: lockgroup_info_array_t?
            var lockGroupCount = mach_msg_type_number_t.max
            try Mach.call(host_lockgroup_info(self.name, &lockGroupInfo, &lockGroupCount))
            return (0..<Int(lockGroupCount)).map {
                LockGroup(rawValue: lockGroupInfo![$0])
            }
        }
    }
}
