import Darwin.Mach

extension Mach {
    /// A flavor of thread info.
    public struct ThreadInfoFlavor: OptionEnum {
        /// The raw value of the flavor.
        public let rawValue: thread_flavor_t

        /// Represents a raw thread info flavor.
        public init(rawValue: thread_flavor_t) { self.rawValue = rawValue }

        /// Basic information about the thread.
        public static let basic = Self(rawValue: thread_flavor_t(THREAD_BASIC_INFO))

        /// Identifying information about the thread.
        public static let identifier = Self(rawValue: thread_flavor_t(THREAD_IDENTIFIER_INFO))

        /// Extended information about the thread.
        public static let extended = Self(rawValue: thread_flavor_t(THREAD_EXTENDED_INFO))

        /// The thread's timesharing policy info.
        @available(
            macOS, deprecated: 10.11.2,
            message:
                "This was marked as obsolete in xnu-3248.20.55, but the info is still retrievable."
        )
        public static let timeshare = Self(rawValue: thread_flavor_t(THREAD_SCHED_TIMESHARE_INFO))

        /// The thread's round robin policy info.
        @available(
            macOS, deprecated: 10.11.2,
            message:
                "This was marked as obsolete in xnu-3248.20.55, but the info is still retrievable."
        )
        public static let roundRobin = Self(rawValue: thread_flavor_t(THREAD_SCHED_RR_INFO))
    }

    /// A thread info manager.
    public struct ThreadInfoManager: FlavoredDataGetter {
        /// The thread port.
        internal let port: Mach.Thread

        /// The thread.
        internal var thread: Mach.Thread { self.port }

        /// Creates a thread info manager.
        public init(thread: Mach.Thread) { self.port = thread }

        /// Gets the thread's info.
        func get<DataType>(_ flavor: Mach.ThreadInfoFlavor, as type: DataType.Type = DataType.self)
            throws
            -> DataType
        where DataType: BitwiseCopyable {
            try Mach.callWithCountInOut(type: type) {
                (array: thread_info_t, count) in
                thread_info(self.thread.name, flavor.rawValue, array, &count)
            }
        }
    }
}

extension Mach.Thread {
    /// The thread's info manager.
    public var info: Mach.ThreadInfoManager { .init(thread: self) }
}

extension Mach.ThreadInfoManager {
    /// Basic information about the thread.
    public var basicInfo: thread_basic_info {
        get throws { try self.get(.basic) }
    }

    /// Identifying information about the thread.
    public var identifyingInfo: thread_identifier_info {
        get throws { try self.get(.identifier) }
    }

    /// Extended information about the thread.
    public var extendedInfo: thread_extended_info {
        get throws { try self.get(.extended) }
    }

    /// The thread's timesharing policy info.
    @available(
        macOS, deprecated: 10.11.2,
        message: "This was marked as obsolete in xnu-3248.20.55, but the info is still retrievable."
    )
    public var timesharingInfo: policy_timeshare_info {
        get throws { try self.get(.timeshare) }
    }

    /// The thread's round robin policy info.
    @available(
        macOS, deprecated: 10.11.2,
        message: "This was marked as obsolete in xnu-3248.20.55, but the info is still retrievable."
    )
    public var roundRobinInfo: policy_rr_info {
        get throws { try self.get(.roundRobin) }
    }
}
