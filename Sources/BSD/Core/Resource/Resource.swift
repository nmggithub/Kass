import Darwin.POSIX
import KassHelpers

extension BSD {
    // MARK: - Priority

    /// A target for setting and getting the priority of.
    public struct PriorityTargetType: KassHelpers.NamedOptionEnum {
        /// The name of the target, if it can be determined.
        public var name: String?

        /// Represents a priority target with an optional name.
        public init(name: String?, rawValue: Int32) {
            self.name = name
            self.rawValue = rawValue
        }

        /// The raw value of the target.
        public let rawValue: Int32

        /// All known priority targets.
        public static let allCases: [Self] = [
            .process,
            .processGroup,
            .user,
            .darwinProcess,
            .darwinThread,
        ]

        /// Targets a process.
        public static let process = Self(name: "process", rawValue: PRIO_PROCESS)

        /// Targets a process group.
        public static let processGroup = Self(name: "processGroup", rawValue: PRIO_PGRP)

        /// Targets a user.
        public static let user = Self(name: "user", rawValue: PRIO_USER)

        /// Targets a Darwin process.
        public static let darwinProcess = Self(name: "darwinProcess", rawValue: PRIO_DARWIN_PROCESS)

        /// Targets a Darwin thread.
        public static let darwinThread = Self(name: "darwinThread", rawValue: PRIO_DARWIN_THREAD)

    }

    /// Gets the priority of a target with a given ID.
    public static func getPriority(for targetType: PriorityTargetType, withID id: id_t) throws
        -> Int32
    {
        return try BSDCore.BSD.call(getpriority(targetType.rawValue, id))
    }

    /// Gets the priority of the current target of the target type.
    public static func getPriority(forCurrent targetType: PriorityTargetType) throws -> Int32 {
        return try self.getPriority(for: targetType, withID: 0)
    }

    /// Sets the priority of a target with a given ID to a given value.
    public static func setPriority(
        for targetType: PriorityTargetType, withID id: id_t, to priority: Int32
    ) throws {
        try BSDCore.BSD.call(setpriority(targetType.rawValue, id, priority))
    }

    /// Gets the priority of the current target of the target type to a given value.
    public static func setPriority(
        forCurrent targetType: PriorityTargetType, to priority: Int32
    ) throws {
        try self.setPriority(for: targetType, withID: 0, to: priority)
    }

    // MARK: - Resource Limits

    /// A resource limit type.
    public struct ResourceLimitType: KassHelpers.NamedOptionEnum {
        /// The name of the limit type, if it can be determined.
        public var name: String?

        /// Represents a resource limit type with an optional name.
        public init(name: String?, rawValue: Int32) {
            self.name = name
            self.rawValue = rawValue
        }

        /// The raw value of limit type.
        public let rawValue: Int32

        /// All known resource limit types.
        public static let allCases: [Self] = []

        public static let cpuTime = Self(
            name: "cpuTime", rawValue: RLIMIT_CPU
        )

        public static let fileSize = Self(
            name: "fileSize", rawValue: RLIMIT_FSIZE
        )

        public static let dataSegmentSize = Self(
            name: "dataSegmentSize", rawValue: RLIMIT_DATA
        )

        public static let stackSize = Self(
            name: "stackSize", rawValue: RLIMIT_STACK
        )
        public static let coreFileSize = Self(
            name: "coreFileSize", rawValue: RLIMIT_CORE
        )

        public static let addressSpace = Self(
            name: "addressSpace", rawValue: RLIMIT_AS
        )

        public static let residentSetSize = Self(
            name: "residentSetSize", rawValue: RLIMIT_RSS
        )

        public static let lockedMemory = Self(
            name: "lockedMemory", rawValue: RLIMIT_MEMLOCK
        )

        public static let numberOfProcesses = Self(
            name: "numberOfProcesses", rawValue: RLIMIT_NPROC
        )

        public static let numberOfOpenFiles = Self(
            name: "numberOfOpenFiles", rawValue: RLIMIT_NOFILE
        )
    }

    /// Gets the resource limit of a given type for the current process.
    public static func getResourceLimit(
        for limitType: ResourceLimitType
    ) throws -> (soft: UInt64, hard: UInt64) {
        var limit = rlimit()
        try BSDCore.BSD.call(getrlimit(limitType.rawValue, &limit))
        return (soft: limit.rlim_cur, hard: limit.rlim_max)
    }

    /// Sets the resource limit of a given type for the current process to a given value.
    public static func setResourceLimit(
        for limitType: ResourceLimitType, to limit: (soft: UInt64, hard: UInt64)
    ) throws {
        var rlimit = rlimit(rlim_cur: limit.soft, rlim_max: limit.hard)
        try BSDCore.BSD.call(setrlimit(limitType.rawValue, &rlimit))
    }

    /// MARK: - Resource Usage

    /// A resource usage target.
    public struct ResourceUsageTarget: KassHelpers.NamedOptionEnum {
        /// The name of the target, if it can be determined.
        public var name: String?

        /// Represents a resource usage target with an optional name.
        public init(name: String?, rawValue: Int32) {
            self.name = name
            self.rawValue = rawValue
        }

        /// The raw value of the target.
        public let rawValue: Int32

        /// All known resource usage targets.
        public static let allCases: [Self] = [
            .currentProcess,
            .currentProcessChildren,
        ]

        /// Target the current process.
        public static let currentProcess = Self(
            name: "currentProcess", rawValue: RUSAGE_SELF
        )

        /// Targets the children of the current process.
        public static let currentProcessChildren = Self(
            name: "currentProcessChildren", rawValue: RUSAGE_CHILDREN
        )
    }

    /// Gets the resource usage of a given target.
    public static func getResourceUsage(
        for target: ResourceUsageTarget
    ) throws -> rusage {
        let usagePointer = UnsafeMutablePointer<rusage>.allocate(capacity: 1)
        defer { usagePointer.deallocate() }
        try BSDCore.BSD.call(getrusage(target.rawValue, usagePointer))
        return usagePointer.pointee
    }
}
