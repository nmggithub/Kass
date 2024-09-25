import Darwin.Mach

extension Mach.Task {
    /// A type of task policy.
    public enum Policy: task_policy_flavor_t {
        case category = 1
        case suppression = 3
        case state = 4
        case baseQoS = 8
        case overrideQoS = 9
        case latencyQoS = 10
        case throughputQoS = 11
    }

    /// Gets the task's policy.
    public func getPolicy<DataType: BitwiseCopyable>(
        _ policy: Policy, as type: DataType.Type = DataType.self
    ) throws -> DataType {
        try Mach.callWithCountInOut(type: type) {
            (array: task_policy_t, count) in
            var dontGetDefault = boolean_t(0)
            return task_policy_get(self.name, policy.rawValue, array, &count, &dontGetDefault)
        }
    }

    /// Sets the task's policy.
    public func setPolicy<DataType: BitwiseCopyable>(
        _ policy: Policy, to value: DataType
    ) throws {
        try Mach.callWithCountIn(value: value) {
            (array: task_policy_t, count) in
            task_policy_set(self.name, policy.rawValue, array, count)
        }
    }
}

extension Mach.Task.Policy {
    /// Gets the policy for a task.
    public func get<DataType: BitwiseCopyable>(
        as type: DataType.Type, for task: Mach.Task = .current
    ) throws -> DataType { try task.getPolicy(self, as: type) }

    /// Sets the policy for a task.
    public func set(
        to value: BitwiseCopyable, for task: Mach.Task = .current
    ) throws { try task.setPolicy(self, to: value) }
}
