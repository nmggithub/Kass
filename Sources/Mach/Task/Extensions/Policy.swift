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
    /// - Parameters:
    ///   - policy: The policy to get.
    ///   - type: The type to load the policy as.
    /// - Throws: An error if the policy cannot be retrieved.
    /// - Returns: The policy.
    public func getPolicy<DataType: BitwiseCopyable>(
        _ policy: Policy, as type: DataType.Type
    ) throws -> DataType {
        try Mach.callWithCountInOut(type: type) {
            (array: task_policy_t, count) in
            task_policy_get(self.name, policy.rawValue, array, &count, nil)
        }
    }

    /// Sets the task's policy.
    /// - Parameters:
    ///   - policy: The policy to set.
    ///   - value: The value to set the policy to.
    /// - Throws: An error if the policy cannot be set.
    public func setPolicy<DataType: BitwiseCopyable>(
        _ policy: Policy, to value: DataType
    ) throws {
        try Mach.callWithCountIn(value: value) {
            (array: task_policy_t, count) in
            task_policy_set(self.name, policy.rawValue, array, count)
        }
    }
}
