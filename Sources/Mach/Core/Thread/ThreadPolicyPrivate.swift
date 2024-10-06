import Darwin.Mach
import KassC.ThreadPolicyPrivate

extension Mach {
    /// A thread's policy state.
    /// - Warning: This work is covered under license. Please view the source code and <doc:MachCore#Licenses> for more information.
    public struct ThreadPolicyState: BitwiseCopyable {
        public let requested: Int32
        public let effective: Int32
        public let flags: Int32
        public let thps_requested_policy: UInt64
        public let thps_effective_policy: UInt64
        public let thps_user_promotions: UInt32
        public let thps_user_promotion_basepri: UInt32
        public let thps_ipc_overrides: UInt32
        public let reserved32: UInt32
        public let reserved1: UInt64
        public let reserved2: UInt64
    }

    /// A thread's QoS policy.
    /// - Warning: This work is covered under license. Please view the source code and <doc:MachCore#Licenses> for more information.
    public struct ThreadQoSPolicy: BitwiseCopyable {
        public let qos_tier: Int32
        public let tier_importance: Int32
    }

    /// A thread's time constraint policy (with a priority field).
    /// - Warning: This work is covered under license. Please view the source code and <doc:MachCore#Licenses> for more information.
    public struct ThreadTimeConstraintWithPriorityPolicy: BitwiseCopyable {
        public let period: UInt32
        public let computation: UInt32
        public let constraint: UInt32
        public let preemptible: Int32
        public let priority: Int32
    }

    /// A thread's requested QoS policy.
    /// - Warning: This work is covered under license. Please view the source code and <doc:MachCore#Licenses> for more information.
    public struct ThreadRequestedQoSPolicy: BitwiseCopyable {
        public let thrq_base_qos: Int32
        public let thrq_qos_relprio: Int32
        public let thrq_qos_override: Int32
        public let thrq_qos_promote: Int32
        public let thrq_qos_kevent_override: Int32
        public let thrq_qos_workq_override: Int32
        public let thrq_qos_wlsvc_override: Int32
    }
}

extension Mach.ThreadPolicyFlavor {
    /// A thread's policy state.
    public static let state = Self(rawValue: UInt32(THREAD_POLICY_STATE))

    /// A thread's QoS policy.
    public static let qos = Self(rawValue: UInt32(THREAD_QOS_POLICY))

    /// A thread's time constraint policy (with a priority field).
    public static let timeConstraintWithPriority = Self(
        rawValue: UInt32(THREAD_TIME_CONSTRAINT_WITH_PRIORITY_POLICY)
    )

    /// A thread's requested QoS policy.
    public static let requestedState = Self(rawValue: UInt32(THREAD_REQUESTED_STATE_POLICY))
}

extension Mach.ThreadPolicyManager {
    /// The thread's policy state.
    /// - Warning: This uses a private policy flavor. Use with caution.
    public var policyState: thread_policy_state {
        get throws { try self.get(.state) }
    }

    /// The thread's QoS policy.
    /// - Warning: This uses a private policy flavor. Use with caution.
    public var qosPolicy: thread_qos_policy {
        get throws { try self.get(.qos) }
    }

    /// Sets the thread's QoS policy.
    /// - Warning: This uses a private policy flavor. Use with caution.
    public func setQoSPolicy(
        to qosPolicy: thread_qos_policy
    ) throws { try self.set(.qos, to: qosPolicy) }

    /// The thread's time constraint policy (with a priority field).
    /// - Warning: This uses a private policy flavor. Use with caution.
    public var timeConstraintWithPriorityPolicy: thread_time_constraint_with_priority_policy {
        get throws { try self.get(.timeConstraintWithPriority) }
    }

    /// Sets the thread's time constraint policy (with a priority field).
    /// - Warning: This uses a private policy flavor. Use with caution.
    public func setTimeConstraintWithPriorityPolicy(
        to timeConstraintWithPriorityPolicy: thread_time_constraint_with_priority_policy
    ) throws { try self.set(.timeConstraintWithPriority, to: timeConstraintWithPriorityPolicy) }

    /// The thread's requested QoS policy.
    /// - Warning: This uses a private policy flavor. Use with caution.
    public var requestedQoSPolicy: thread_requested_qos_policy {
        get throws { try self.get(.requestedState) }
    }
}
