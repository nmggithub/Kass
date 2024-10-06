import Darwin.Mach
import KassHelpers

extension Mach {
    /// A flavor of task policy.
    public struct TaskPolicyFlavor: KassHelpers.OptionEnum {
        /// The raw value of the flavor.
        public let rawValue: task_policy_flavor_t

        /// Represents a raw task policy flavor.
        public init(rawValue: task_policy_flavor_t) { self.rawValue = rawValue }

        /// A task's category policy.
        public static let category = Self(rawValue: task_policy_flavor_t(TASK_CATEGORY_POLICY))

        /// A task's suppression policy.
        public static let suppression = Self(
            rawValue: task_policy_flavor_t(TASK_SUPPRESSION_POLICY)
        )

        /// A task's policy state.
        public static let state = Self(rawValue: task_policy_flavor_t(TASK_POLICY_STATE))

        /// A task's QoS policy.
        public static let baseQoS = Self(rawValue: task_policy_flavor_t(TASK_BASE_QOS_POLICY))

        /// A task's override QoS policy.
        public static let overrideQoS = Self(
            rawValue: task_policy_flavor_t(TASK_OVERRIDE_QOS_POLICY)
        )

        /// A task's latency QoS policy.
        public static let latencyQoS = Self(
            rawValue: task_policy_flavor_t(TASK_BASE_LATENCY_QOS_POLICY)
        )

        /// A task's throughput QoS policy.
        public static let throughputQoS = Self(
            rawValue: task_policy_flavor_t(TASK_BASE_THROUGHPUT_QOS_POLICY)
        )
    }

    /// A task policy manager.
    public struct TaskPolicyManager: FlavoredDataManager {
        /// The task port.
        public let port: Mach.Task

        /// The task.
        internal var task: Mach.Task { self.port }

        /// Creates a task policy manager.
        public init(task: Mach.Task) { self.port = task }

        /// Gets the task's policy.
        public func get<DataType: BitwiseCopyable>(
            _ flavor: Mach.TaskPolicyFlavor, as type: DataType.Type = DataType.self
        ) throws -> DataType {
            try Mach.callWithCountInOut(type: type) {
                (array: task_policy_t, count) in
                var dontGetDefault = boolean_t(0)
                return task_policy_get(
                    self.task.name, flavor.rawValue, array, &count, &dontGetDefault
                )
            }
        }

        /// Sets the task's policy.
        public func set<DataType: BitwiseCopyable>(
            _ flavor: Mach.TaskPolicyFlavor, to value: DataType
        ) throws {
            try Mach.callWithCountIn(value: value) {
                (array: task_policy_t, count) in
                task_policy_set(self.port.name, flavor.rawValue, array, count)
            }
        }
    }
}

extension Mach.Task {
    /// The task's policy.
    public var policy: Mach.TaskPolicyManager { .init(task: self) }
}

extension Mach.TaskPolicyManager {
    /// The task's category policy.
    public var categoryPolicy: task_category_policy {
        get throws { try self.get(.category) }
    }

    /// Sets the task's category policy.
    public func setCategoryPolicy(to categoryPolicy: task_category_policy) throws {
        try self.set(.category, to: categoryPolicy)
    }

    /// The task's QoS policy.
    public var qosPolicy: task_qos_policy {
        get throws { try self.get(.baseQoS) }
    }

    /// Sets the task's QoS policy.
    public func setQoSPolicy(to qosPolicy: task_qos_policy) throws {
        try self.set(.baseQoS, to: qosPolicy)
    }

    /// Set's the task's latency QoS policy.
    public func setLatencyQoSPolicy(to qosPolicy: task_qos_policy) throws {
        try self.set(.latencyQoS, to: qosPolicy)
    }

    /// Set's the task's throughput QoS policy.
    public func setThroughputQoSPolicy(to qosPolicy: task_qos_policy) throws {
        try self.set(.throughputQoS, to: qosPolicy)
    }
}
