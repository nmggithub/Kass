import Darwin.Mach

extension Mach {
    /// A type of task info.
    public enum TaskInfo: task_flavor_t {
        /// Basic information about the task.
        @available(macOS, deprecated: 10.8, message: "Use `basic` instead.")
        case basic32 = 4

        /// Like ``basic32``, but with the maximum resident size instead of the current size.
        @available(macOS, deprecated: 10.8, message: "Use `basic` instead.")
        case basic2_32 = 6

        /// Basic information about the task (64-bit compatible, older version).
        @available(macOS, deprecated: 10.8, message: "Use `basic` instead.")
        case basic64 = 5

        /// Counts of specific events on the task.
        case events = 2

        /// Total thread run times for the task.
        case threadTimes = 3

        /// Absolute times for the task.
        case absoluteTimes = 1

        /// Kernel memory information for the task.
        case kernelMemory = 7

        /// The task's security token.
        case securityToken = 13

        /// The task's audit token.
        case auditToken = 15

        /// The task's affinity tag information.
        case affinityTag = 16

        /// Information about dyld images in the task.
        case dyld = 17

        #if arch(arm) || arch(arm64)

            /// Basic information about the task (64-bit compatible, "newer" version).
            /// - Note: This appears to have been introduced in xnu-4570.1.46, which was released with
            /// OS X 10.13. However, it seems to have only been a compatibility patch and wasn't meant
            /// for general use. It also appears to be related to iOS (but since macOS and iOS use the
            /// same kernel, it's available on macOS as well).
            /// - Important: This is only available on the ARM architecture.
            @available(macOS, introduced: 10.13, deprecated: 10.13, message: "Use `basic` instead.")
            case basic64_2 = 18
        #endif

        /// Information about external modifications to the task.
        case extmod = 19

        /// Basic information about the task.
        case basic = 20

        /// Information about the task's power usage.
        case power = 21

        /// Information about the task's power usage (newer version).
        case powerV2 = 26

        /// Information about the task's virtual memory usage.
        case vm = 22

        /// Information about the task's virtual memory usage, including purgeable memory.
        case vmPurgeable = 23

        /// Time values for how long threads in the task have been in wait states.
        /// - Note: This was introduced in OS X 10.10, but with a code comment saying it was
        /// deprecated and may not be accurate. However, it's still available to this day.
        @available(macOS, introduced: 10.10, deprecated: 10.10, message: "May not be accurate.")
        case waitTimes = 25

        /// The task's flags.
        case flags = 28
    }
}

extension Mach.Task {
    /// Gets the task's info.
    public func getInfo<DataType: BitwiseCopyable>(
        _ info: Mach.TaskInfo, as type: DataType.Type = DataType.self
    ) throws -> DataType {
        try Mach.callWithCountInOut(type: type) {
            (array: task_info_t, count) in
            task_info(self.name, info.rawValue, array, &count)
        }
    }
}

extension Mach.Task {
    /// Basic information about the task.
    @available(macOS, deprecated: 10.8, message: "Use `basicInfo` instead.")
    public var basicInfo32: task_basic_info_32 {
        get throws { try self.getInfo(.basic32) }
    }

    /// Like ``basicInfo32``, but with the maximum resident size instead of the current size.
    @available(macOS, deprecated: 10.8, message: "Use `basicInfo` instead.")
    public var basicInfo32_2: task_basic_info_32 {
        get throws { try self.getInfo(.basic2_32) }
    }

    /// Basic information about the task (64-bit compatible, older version).
    @available(macOS, deprecated: 10.8, message: "Use `basicInfo` instead.")
    public var basicInfo64: task_basic_info_64 {
        get throws { try self.getInfo(.basic64) }
    }

    /// Counts of specific events on the task.
    public var eventCounts: task_events_info {
        get throws { try self.getInfo(.events) }
    }

    /// Total thread run times for the task.
    public var threadTimes: task_thread_times_info {
        get throws { try self.getInfo(.threadTimes) }
    }

    /// Absolute times for the task.
    public var absoluteTimes: task_absolutetime_info {
        get throws { try self.getInfo(.absoluteTimes) }
    }

    /// Kernel memory information for the task.
    public var kernelMemoryInfo: task_kernelmemory_info {
        get throws { try self.getInfo(.kernelMemory) }
    }

    /// The task's security token.
    public var securityToken: security_token_t {
        get throws { try self.getInfo(.securityToken) }
    }

    /// The task's audit token.
    public var auditToken: audit_token_t {
        get throws { try self.getInfo(.auditToken) }
    }

    /// The task's affinity tag information.
    public var affinityTagInfo: task_affinity_tag_info {
        get throws { try self.getInfo(.affinityTag) }
    }

    #if arch(arm) || arch(arm64)

        /// Basic information about the task (64-bit compatible, "newer" version).
        /// - Note: This appears to have been introduced in xnu-4570.1.46, which was released with
        /// OS X 10.13. However, it seems to have only been a compatibility patch and wasn't meant
        /// for general use. It also appears to be related to iOS (but since macOS and iOS use the
        /// same kernel, it's available on macOS as well).
        /// - Important: This is only available on the ARM architecture.
        @available(macOS, introduced: 10.13, deprecated: 10.13, message: "Use `basicInfo` instead.")
        public var basicInfo64_2: task_basic_info_64_2 {
            get throws { try self.getInfo(.basic64_2) }
        }

    #endif

    /// Information about external modifications to the task.
    public var extmodInfo: task_extmod_info {
        get throws { try self.getInfo(.extmod) }
    }

    /// Basic information about the task.
    public var basicInfo: mach_task_basic_info {
        get throws { try self.getInfo(.basic) }
    }

    /// Information about the task's power usage.
    public var powerInfo: task_power_info {
        get throws { try self.getInfo(.power) }
    }

    /// Information about the task's power usage (newer version).
    public var powerInfoV2: task_power_info_v2 {
        get throws { try self.getInfo(.powerV2) }
    }

    /// Information about the task's virtual memory usage.
    public var vmInfo: task_vm_info {
        get throws { try self.getInfo(.vm) }
    }

    /// Information about the task's virtual memory usage, including purgeable memory.
    public var vmPurgeableInfo: task_vm_info {
        get throws { try self.getInfo(.vmPurgeable) }
    }

    /// Time values for how long threads in the task have been in wait states.
    /// - Note: This was introduced in OS X 10.10, but with a code comment saying it was
    /// deprecated and may not be accurate. However, it's still available to this day.
    @available(macOS, introduced: 10.10, deprecated: 10.10, message: "May not be accurate.")
    public var waitTimes: task_wait_state_info {
        get throws { try self.getInfo(.waitTimes) }
    }

    /// The task's flags.
    public var flags: task_flags_info {
        get throws { try self.getInfo(.flags) }
    }
}

extension Mach.TaskInfo {
    /// Gets the information for a given task.
    public func get<DataType: BitwiseCopyable>(
        as type: DataType.Type = DataType.self, for task: Mach.Task
    ) throws -> DataType { try task.getInfo(self) }
}
