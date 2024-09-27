import Darwin.Mach

extension Mach {
    /// A type of thread policy.
    public enum ThreadPolicy: thread_policy_flavor_t {
        /// A thread's extended policy.
        /// - Note: This is called an "extended" policy, but what it's extending is an empty structure. So it's really just a policy.
        case extended = 1

        /// A thread's time constraint policy.
        case timeConstraint = 2

        /// A thread's precedence policy.
        case precedence = 3

        /// A thread's affinity policy.
        case affinity = 4

        /// A thread's latency QoS policy.
        case latencyQoS = 7

        /// A thread's throughput QoS policy.
        case throughputQoS = 8
    }
}

extension Mach.Thread {
    /// Gets the thread's policy.
    public func getPolicy<DataType: BitwiseCopyable>(
        _ policy: Mach.ThreadPolicy, as type: DataType.Type = DataType.self
    ) throws -> DataType {
        try Mach.callWithCountInOut(type: type) {
            (array: thread_policy_t, count) in
            var dontGetDefault = boolean_t(0)
            return thread_policy_get(self.name, policy.rawValue, array, &count, &dontGetDefault)
        }
    }

    /// Sets the thread's policy.
    public func setPolicy<DataType: BitwiseCopyable>(
        _ policy: Mach.ThreadPolicy, to value: DataType
    ) throws {
        try Mach.callWithCountIn(value: value) {
            (array: thread_policy_t, count) in
            thread_policy_set(self.name, policy.rawValue, array, count)
        }
    }
}

extension Mach.ThreadPolicy {
    /// Gets the policy for a thread.
    public func get<DataType: BitwiseCopyable>(
        as type: DataType.Type, for thread: Mach.Thread = .current
    ) throws -> DataType { try thread.getPolicy(self, as: type) }

    /// Sets the policy for a thread.
    public func set(
        to value: BitwiseCopyable, for thread: Mach.Thread = .current
    ) throws { try thread.setPolicy(self, to: value) }
}

extension Mach.Thread {
    /// The thread's extended policy.
    public var extendedPolicy: thread_extended_policy {
        get throws { try self.getPolicy(.extended) }
    }

    /// Sets the thread's extended policy.
    public func setExtendedPolicy(
        _ extendedPolicy: thread_extended_policy
    ) throws { try self.setPolicy(.extended, to: extendedPolicy) }

    /// The thread's time constraint policy.
    public var timeConstraintPolicy: thread_time_constraint_policy {
        get throws { try self.getPolicy(.timeConstraint) }
    }

    /// Sets the thread's time constraint policy.
    public func setTimeConstraintPolicy(
        _ timeConstraintPolicy: thread_time_constraint_policy
    ) throws { try self.setPolicy(.timeConstraint, to: timeConstraintPolicy) }

    /// The thread's precedence policy.
    public var precedencePolicy: thread_precedence_policy {
        get throws { try self.getPolicy(.precedence) }
    }

    /// Sets the thread's precedence policy.
    public func setPrecedencePolicy(
        _ precedencePolicy: thread_precedence_policy
    ) throws { try self.setPolicy(.precedence, to: precedencePolicy) }

    /// The thread's affinity policy.
    public var affinityPolicy: thread_affinity_policy {
        get throws { try self.getPolicy(.affinity) }
    }

    /// Sets the thread's affinity policy.
    public func setAffinityPolicy(
        _ affinityPolicy: thread_affinity_policy
    ) throws { try self.setPolicy(.affinity, to: affinityPolicy) }

    /// The thread's latency QoS policy.
    public var latencyQoSPolicy: thread_latency_qos_policy {
        get throws { try self.getPolicy(.latencyQoS) }
    }

    /// Sets the thread's latency QoS policy.
    public func setLatencyQoSPolicy(
        _ latencyQoSPolicy: thread_latency_qos_policy
    ) throws { try self.setPolicy(.latencyQoS, to: latencyQoSPolicy) }

    /// The thread's throughput QoS policy.
    public var throughputQoSPolicy: thread_throughput_qos_policy {
        get throws { try self.getPolicy(.throughputQoS) }
    }

    /// Sets the thread's throughput QoS policy.
    public func setThroughputQoSPolicy(
        _ throughputQoSPolicy: thread_throughput_qos_policy
    ) throws { try self.setPolicy(.throughputQoS, to: throughputQoSPolicy) }
}
