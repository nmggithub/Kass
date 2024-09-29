import Darwin.Mach

extension Mach {
    /// A type of thread info.
    public enum ThreadInfoFlavor: thread_flavor_t {
        /// Basic information about the thread.
        case basic = 3

        /// Identifying information about the thread.
        case identifier = 4

        /// Extended information about the thread.
        case extended = 5

        /// The thread's timesharing policy info.
        @available(
            macOS, deprecated: 10.11.2,
            message:
                "This was marked as obsolete in xnu-3248.20.55, but the info is still retrievable."
        )
        case timeshare = 10

        /// The thread's round robin policy info.
        @available(
            macOS, deprecated: 10.11.2,
            message:
                "This was marked as obsolete in xnu-3248.20.55, but the info is still retrievable."
        )
        case roundRobin = 11
    }
}

extension Mach.Thread {
    /// Gets the thread's info.
    public func getInfo<DataType: BitwiseCopyable>(
        _ info: Mach.ThreadInfoFlavor, as type: DataType.Type = DataType.self
    ) throws -> DataType {
        try Mach.callWithCountInOut(type: type) {
            (array: thread_info_t, count) in
            thread_info(self.name, info.rawValue, array, &count)
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
