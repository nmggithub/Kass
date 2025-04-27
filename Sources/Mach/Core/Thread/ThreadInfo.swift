import Darwin.Mach
import KassHelpers

extension Mach {
    /// A flavor of thread info.
    public struct ThreadInfoFlavor: KassHelpers.OptionEnum {
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
        /// The thread.
        public let thread: Mach.Thread

        /// Creates a thread info manager.
        public init(thread: Mach.Thread) { self.thread = thread }

        /// Gets the thread's info.
        public func get<DataType>(
            _ flavor: Mach.ThreadInfoFlavor, as type: DataType.Type = DataType.self
        ) throws -> DataType where DataType: BitwiseCopyable {
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

extension Mach {
    /// A run state of a thread.
    public struct ThreadRunState: KassHelpers.NamedOptionEnum {
        /// The name of the run state, if it can be determined.
        public var name: String?

        // Represents a run state with an optional name.
        public init(name: String?, rawValue: integer_t) {
            self.name = name
            self.rawValue = rawValue
        }

        /// The raw value of the run state.
        public let rawValue: integer_t

        /// All known run states.
        public static let allCases: [ThreadRunState] =
            [.running, stopped, waiting, uninterruptible, halted]

        /// The thread is running normally.
        public static let running = Self(
            name: "running", rawValue: TH_STATE_RUNNING
        )

        /// The thread is stopped.
        public static let stopped = Self(
            name: "stopped", rawValue: TH_STATE_STOPPED
        )

        /// The thread is waiting normally.
        public static let waiting = Self(
            name: "waiting", rawValue: TH_STATE_WAITING
        )

        /// The thread is in an uninterruptible wait.
        public static let uninterruptible = Self(
            name: "uninterruptible", rawValue: TH_STATE_UNINTERRUPTIBLE
        )

        /// The thread is halted at a clean point.
        public static let halted = Self(
            name: "halted", rawValue: TH_STATE_HALTED
        )

    }
}

extension thread_basic_info {
    /// The thread's run state.
    public var runState: Mach.ThreadRunState {
        Mach.ThreadRunState(rawValue: self.run_state)
    }
}
