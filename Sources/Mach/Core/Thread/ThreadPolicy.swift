import Darwin.Mach

extension Mach {
    /// A flavor of thread policy.
    public struct ThreadPolicyFlavor: OptionEnum {
        /// The raw value of the flavor.
        public let rawValue: thread_policy_flavor_t

        /// Represents a raw flavor of thread policy.
        public init(rawValue: thread_policy_flavor_t) { self.rawValue = rawValue }

        /// A thread's extended policy.
        /// - Note: This is called an "extended" policy, but what it's extending is an empty structure. So it's really just a policy.
        public static let extended = Self(rawValue: thread_policy_flavor_t(THREAD_EXTENDED_POLICY))

        /// A thread's time constraint policy.
        public static let timeConstraint = Self(
            rawValue: thread_policy_flavor_t(THREAD_TIME_CONSTRAINT_POLICY)
        )

        /// A thread's precedence policy.
        public static let precedence = Self(
            rawValue: thread_policy_flavor_t(THREAD_PRECEDENCE_POLICY)
        )

        /// A thread's affinity policy.
        public static let affinity = Self(rawValue: thread_policy_flavor_t(THREAD_AFFINITY_POLICY))

        /// A thread's latency QoS policy.
        public static let latencyQoS = Self(
            rawValue: thread_policy_flavor_t(THREAD_LATENCY_QOS_POLICY)
        )

        /// A thread's throughput QoS policy.
        public static let throughputQoS = Self(
            rawValue: thread_policy_flavor_t(THREAD_THROUGHPUT_QOS_POLICY)
        )
    }

    /// A thread policy manager.
    public struct ThreadPolicyManager: FlavoredDataManager {
        /// The thread port.
        internal let port: Mach.Thread

        /// The thread.
        internal var thread: Mach.Thread { self.port }

        /// Creates a thread policy manager.
        public init(thread: Mach.Thread) { self.port = thread }

        /// Gets the thread's policy.
        public func get<DataType>(
            _ flavor: Mach.ThreadPolicyFlavor, as type: DataType.Type = DataType.self
        ) throws
            -> DataType where DataType: BitwiseCopyable
        {
            try Mach.callWithCountInOut(type: type) {
                (array: thread_policy_t, count) in
                var dontGetDefault = boolean_t(0)
                return thread_policy_get(
                    self.thread.name, flavor.rawValue, array, &count, &dontGetDefault)
            }
        }

        /// Sets the thread's policy.
        public func set<DataType>(_ flavor: Mach.ThreadPolicyFlavor, to value: DataType) throws
        where DataType: BitwiseCopyable {
            try Mach.callWithCountIn(value: value) {
                (array: thread_policy_t, count) in
                thread_policy_set(self.thread.name, flavor.rawValue, array, count)
            }
        }
    }
}

extension Mach.Thread {
    /// The thread's policy.
    public var policy: Mach.ThreadPolicyManager { .init(thread: self) }
}

extension Mach.ThreadPolicyManager {
    /// The thread's extended policy.
    public var extendedPolicy: thread_extended_policy {
        get throws { try self.get(.extended) }
    }

    /// Sets the thread's extended policy.
    public func setExtendedPolicy(
        to extendedPolicy: thread_extended_policy
    ) throws { try self.set(.extended, to: extendedPolicy) }

    /// The thread's time constraint policy.
    public var timeConstraintPolicy: thread_time_constraint_policy {
        get throws { try self.get(.timeConstraint) }
    }

    /// Sets the thread's time constraint policy.
    public func setTimeConstraintPolicy(
        to timeConstraintPolicy: thread_time_constraint_policy
    ) throws { try self.set(.timeConstraint, to: timeConstraintPolicy) }

    /// The thread's precedence policy.
    public var precedencePolicy: thread_precedence_policy {
        get throws { try self.get(.precedence) }
    }

    /// Sets the thread's precedence policy.
    public func setPrecedencePolicy(
        to precedencePolicy: thread_precedence_policy
    ) throws { try self.set(.precedence, to: precedencePolicy) }

    /// The thread's affinity policy.
    public var affinityPolicy: thread_affinity_policy {
        get throws { try self.get(.affinity) }
    }

    /// Sets the thread's affinity policy.
    public func setAffinityPolicy(
        to affinityPolicy: thread_affinity_policy
    ) throws { try self.set(.affinity, to: affinityPolicy) }

    /// The thread's latency QoS policy.
    public var latencyQoSPolicy: thread_latency_qos_policy {
        get throws { try self.get(.latencyQoS) }
    }

    /// Sets the thread's latency QoS policy.
    public func setLatencyQoSPolicy(
        to latencyQoSPolicy: thread_latency_qos_policy
    ) throws { try self.set(.latencyQoS, to: latencyQoSPolicy) }

    /// The thread's throughput QoS policy.
    public var throughputQoSPolicy: thread_throughput_qos_policy {
        get throws { try self.get(.throughputQoS) }
    }

    /// Sets the thread's throughput QoS policy.
    public func setThroughputQoSPolicy(
        to throughputQoSPolicy: thread_throughput_qos_policy
    ) throws { try self.set(.throughputQoS, to: throughputQoSPolicy) }
}
