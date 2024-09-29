import Darwin.Mach

extension Mach {
    /// A flavor of thread info.
    public struct ThreadInfoFlavor: OptionEnum {
        public let rawValue: thread_flavor_t
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
}

extension Mach.Thread {
    /// Gets the thread's info.
    public func getInfo<DataType: BitwiseCopyable>(
        _ flavor: Mach.ThreadInfoFlavor, as type: DataType.Type = DataType.self
    ) throws -> DataType {
        try Mach.callWithCountInOut(type: type) {
            (array: thread_info_t, count) in
            thread_info(self.name, flavor.rawValue, array, &count)
        }
    }
}

extension Mach.Thread {
    /// Basic information about the thread.
    public var basicInfo: thread_basic_info {
        get throws { try self.getInfo(.basic) }
    }

    /// Identifying information about the thread.
    public var identifyingInfo: thread_identifier_info {
        get throws { try self.getInfo(.identifier) }
    }

    /// Extended information about the thread.
    public var extendedInfo: thread_extended_info {
        get throws { try self.getInfo(.extended) }
    }

    /// The thread's timesharing policy info.
    @available(
        macOS, deprecated: 10.11.2,
        message: "This was marked as obsolete in xnu-3248.20.55, but the info is still retrievable."
    )
    public var timesharingInfo: policy_timeshare_info {
        get throws { try self.getInfo(.timeshare) }
    }

    /// The thread's round robin policy info.
    @available(
        macOS, deprecated: 10.11.2,
        message: "This was marked as obsolete in xnu-3248.20.55, but the info is still retrievable."
    )
    public var roundRobinInfo: policy_rr_info {
        get throws { try self.getInfo(.roundRobin) }
    }
}
