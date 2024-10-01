import MachC.TaskPolicyPrivate

extension Mach.TaskPolicyManager {
    /// The task's suppression policy.
    public var suppressionPolicy: task_suppression_policy {
        get throws { try self.get(.suppression) }
    }

    /// Set's the task's suppression policy.
    public func setSuppressionPolicy(to suppressionPolicy: task_suppression_policy) throws {
        try self.set(.suppression, to: suppressionPolicy)
    }

    /// The task's policy state.
    /// - Important: Only privileged tasks can get this.
    public var policyState: task_policy_state {
        get throws { try self.get(.state) }
    }
}
