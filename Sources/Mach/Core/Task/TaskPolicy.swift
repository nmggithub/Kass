import Darwin.Mach

extension Mach {
    /// A type of task policy.
    public struct TaskPolicyFlavor: RawRepresentable, Hashable, Sendable {
        public let rawValue: task_policy_flavor_t
        public init(rawValue: task_policy_flavor_t) { self.rawValue = rawValue }

        public static let category = Self(rawValue: task_policy_flavor_t(TASK_CATEGORY_POLICY))
        public static let suppression = Self(
            rawValue: task_policy_flavor_t(TASK_SUPPRESSION_POLICY)
        )
        public static let state = Self(rawValue: task_policy_flavor_t(TASK_POLICY_STATE))
        public static let baseQoS = Self(rawValue: task_policy_flavor_t(TASK_BASE_QOS_POLICY))
        public static let overrideQoS = Self(
            rawValue: task_policy_flavor_t(TASK_OVERRIDE_QOS_POLICY)
        )
        public static let latencyQoS = Self(
            rawValue: task_policy_flavor_t(TASK_BASE_LATENCY_QOS_POLICY)
        )
        public static let throughputQoS = Self(
            rawValue: task_policy_flavor_t(TASK_BASE_THROUGHPUT_QOS_POLICY)
        )
    }
}

extension Mach.Task {
    /// Gets the task's policy.
    public func getPolicy<DataType: BitwiseCopyable>(
        _ policy: Mach.TaskPolicyFlavor, as type: DataType.Type = DataType.self
    ) throws -> DataType {
        try Mach.callWithCountInOut(type: type) {
            (array: task_policy_t, count) in
            var dontGetDefault = boolean_t(0)
            return task_policy_get(self.name, policy.rawValue, array, &count, &dontGetDefault)
        }
    }

    /// Sets the task's policy.
    public func setPolicy<DataType: BitwiseCopyable>(
        _ policy: Mach.TaskPolicyFlavor, to value: DataType
    ) throws {
        try Mach.callWithCountIn(value: value) {
            (array: task_policy_t, count) in
            task_policy_set(self.name, policy.rawValue, array, count)
        }
    }
}

extension Mach.TaskPolicyFlavor {
    /// Gets the policy for a task.
    public func get<DataType: BitwiseCopyable>(
        as type: DataType.Type, for task: Mach.Task = .current
    ) throws -> DataType { try task.getPolicy(self, as: type) }

    /// Sets the policy for a task.
    public func set(
        to value: BitwiseCopyable, for task: Mach.Task = .current
    ) throws { try task.setPolicy(self, to: value) }
}

extension Mach.Task {
    /// The task's category policy.
    public var categoryPolicy: task_category_policy {
        get throws { try self.getPolicy(.category) }
    }

    /// Sets the task's category policy.
    public func setCategoryPolicy(_ categoryPolicy: task_category_policy) throws {
        try self.setPolicy(.category, to: categoryPolicy)
    }

    /// The task's QoS policy.
    public var qosPolicy: task_qos_policy {
        get throws { try self.getPolicy(.baseQoS) }
    }

    /// Sets the task's QoS policy.
    public func setQoSPolicy(_ qosPolicy: task_qos_policy) throws {
        try self.setPolicy(.baseQoS, to: qosPolicy)
    }

    /// Set's the task's latency QoS policy.
    public func setLatencyQoSPolicy(_ qosPolicy: task_qos_policy) throws {
        try self.setPolicy(.latencyQoS, to: qosPolicy)
    }

    /// Set's the task's throughput QoS policy.
    public func setThroughputQoSPolicy(_ qosPolicy: task_qos_policy) throws {
        try self.setPolicy(.throughputQoS, to: qosPolicy)
    }
}
