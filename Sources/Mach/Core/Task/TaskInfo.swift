import Darwin.Mach

extension Mach {
    /// A flavor of task info.
    public struct TaskInfoFlavor: OptionEnum {
        public let rawValue: task_flavor_t
        public init(rawValue: task_flavor_t) { self.rawValue = rawValue }

        /// Basic information about the task.
        @available(macOS, deprecated: 10.8, message: "Use `basic` instead.")
        public static let basic32 = Self(rawValue: task_flavor_t(TASK_BASIC_INFO_32))

        /// Like ``basic32``, but with the maximum resident size instead of the current size.
        @available(macOS, deprecated: 10.8, message: "Use `basic` instead.")
        public static let basic2_32 = Self(rawValue: task_flavor_t(TASK_BASIC2_INFO_32))

        /// Basic information about the task (64-bit compatible, older version).
        @available(macOS, deprecated: 10.8, message: "Use `basic` instead.")
        public static let basic64 = Self(rawValue: task_flavor_t(TASK_BASIC_INFO_64))

        /// Counts of specific events on the task.
        public static let events = Self(rawValue: task_flavor_t(TASK_EVENTS_INFO))

        /// Total thread run times for the task.
        public static let threadTimes = Self(rawValue: task_flavor_t(TASK_THREAD_TIMES_INFO))

        /// Absolute times for the task.
        public static let absoluteTimes = Self(rawValue: task_flavor_t(TASK_ABSOLUTETIME_INFO))

        /// Kernel memory information for the task.
        public static let kernelMemory = Self(rawValue: task_flavor_t(TASK_KERNELMEMORY_INFO))

        /// The task's security token.
        public static let securityToken = Self(rawValue: task_flavor_t(TASK_SECURITY_TOKEN))

        /// The task's audit token.
        public static let auditToken = Self(rawValue: task_flavor_t(TASK_AUDIT_TOKEN))

        /// The task's affinity tag information.
        public static let affinityTag = Self(rawValue: task_flavor_t(TASK_AFFINITY_TAG_INFO))

        /// Information about dyld images in the task.
        public static let dyld = Self(rawValue: task_flavor_t(TASK_DYLD_INFO))

        #if arch(arm) || arch(arm64)

            /// Basic information about the task (64-bit compatible, "newer" version).
            /// - Note: This appears to have been introduced in xnu-4570.1.46, which was released with
            /// OS X 10.13. However, it seems to have only been a compatibility patch and wasn't meant
            /// for general use. It also appears to be related to iOS (but since macOS and iOS use the
            /// same kernel, it's available on macOS as well).
            /// - Important: This is only available on the ARM architecture.
            @available(macOS, introduced: 10.13, deprecated: 10.13, message: "Use `basic` instead.")
            public static let basic64_2 = Self(rawValue: task_flavor_t(TASK_BASIC_INFO_64_2))
        #endif

        /// Information about external modifications to the task.
        public static let extmod = Self(rawValue: task_flavor_t(TASK_EXTMOD_INFO))

        /// Basic information about the task.
        public static let basic = Self(rawValue: task_flavor_t(TASK_BASIC_INFO))

        /// Information about the task's power usage.
        public static let power = Self(rawValue: task_flavor_t(TASK_POWER_INFO))

        /// Information about the task's power usage (newer version).
        public static let powerV2 = Self(rawValue: task_flavor_t(TASK_POWER_INFO_V2))

        /// Information about the task's virtual memory usage.
        public static let vm = Self(rawValue: task_flavor_t(TASK_VM_INFO))

        /// Information about the task's virtual memory usage, including purgeable memory.
        public static let vmPurgeable = Self(rawValue: task_flavor_t(TASK_VM_INFO_PURGEABLE))

        /// Time values for how long threads in the task have been in wait states.
        /// - Note: This was introduced in OS X 10.10, but with a code comment saying it was
        /// deprecated and may not be accurate. However, it's still available to this day.
        @available(macOS, introduced: 10.10, deprecated: 10.10, message: "May not be accurate.")
        public static let waitTimes = Self(rawValue: task_flavor_t(TASK_WAIT_STATE_INFO))

        /// The task's flags.
        public static let flags = Self(rawValue: task_flavor_t(TASK_FLAGS_INFO))
    }
}

extension Mach.Task {
    /// Gets the task's info.
    public func getInfo<DataType: BitwiseCopyable>(
        _ flavor: Mach.TaskInfoFlavor, as type: DataType.Type = DataType.self
    ) throws -> DataType {
        try Mach.callWithCountInOut(type: type) {
            (array: task_info_t, count) in
            task_info(self.name, flavor.rawValue, array, &count)
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
    public var basic2Info32: task_basic_info_32 {
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

extension Mach.TaskInfoFlavor {
    /// Gets the information for a given task.
    public func get<DataType: BitwiseCopyable>(
        as type: DataType.Type = DataType.self, for task: Mach.Task
    ) throws -> DataType { try task.getInfo(self) }
}
