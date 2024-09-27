/*
 * Portions Copyright (c) 2022 Apple Inc. All rights reserved.
 *
 * The structures for these policies are not included in the public
 * header files. They are taken from the XNU source code.
 *
 * @APPLE_OSREFERENCE_LICENSE_HEADER_START@
 *
 * This file contains Original Code and/or Modifications of Original Code
 * as defined in and that are subject to the Apple Public Source License
 * Version 2.0 (the 'License'). You may not use this file except in
 * compliance with the License. The rights granted to you under the License
 * may not be used to create, or enable the creation or redistribution of,
 * unlawful or unlicensed copies of an Apple operating system, or to
 * circumvent, violate, or enable the circumvention or violation of, any
 * terms of an Apple operating system software license agreement.
 *
 * Please obtain a copy of the License at
 * http://www.opensource.apple.com/apsl/ and read it before using this file.
 *
 * The Original Code and all software distributed under the License are
 * distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER
 * EXPRESS OR IMPLIED, AND APPLE HEREBY DISCLAIMS ALL SUCH WARRANTIES,
 * INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT.
 * Please see the License for the specific language governing rights and
 * limitations under the License.
 *
 * @APPLE_OSREFERENCE_LICENSE_HEADER_END@
 */

import Darwin.Mach

private let THREAD_POLICY_STATE: thread_policy_flavor_t = 6
private let THREAD_QOS_POLICY: thread_policy_flavor_t = 9
private let THREAD_TIME_CONSTRAINT_WITH_PRIORITY_POLICY: thread_policy_flavor_t = 10
private let THREAD_REQUESTED_STATE_POLICY: thread_policy_flavor_t = 11

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

extension Mach.Thread {
    /// Gets the thread's policy using a raw policy flavor.
    fileprivate func getPolicy<DataType: BitwiseCopyable>(
        _ policy: thread_policy_flavor_t, as type: DataType.Type = DataType.self
    ) throws -> DataType {
        try Mach.callWithCountInOut(type: type) {
            (array: thread_policy_t, count) in
            var dontGetDefault = boolean_t(0)
            return thread_policy_get(self.name, policy, array, &count, &dontGetDefault)
        }
    }

    /// Sets the thread's policy using a raw policy flavor.
    fileprivate func setPolicy<DataType: BitwiseCopyable>(
        _ policy: thread_policy_flavor_t, to value: DataType
    ) throws {
        try Mach.callWithCountIn(value: value) {
            (array: thread_policy_t, count) in
            thread_policy_set(self.name, policy, array, count)
        }
    }
}

extension Mach.Thread {
    /// The thread's policy state.
    /// - Warning: This uses a private policy flavor. Use at your own risk.
    public var policyState: Mach.ThreadPolicyState {
        get throws { try self.getPolicy(THREAD_POLICY_STATE) }
    }

    /// The thread's QoS policy.
    /// - Warning: This uses a private policy flavor. Use at your own risk.
    public var qosPolicy: Mach.ThreadQoSPolicy {
        get throws { try self.getPolicy(THREAD_QOS_POLICY) }
    }

    /// Sets the thread's QoS policy.
    /// - Warning: This uses a private policy flavor. Use at your own risk.
    public func setQoSPolicy(
        _ qosPolicy: Mach.ThreadQoSPolicy
    ) throws { try self.setPolicy(THREAD_QOS_POLICY, to: qosPolicy) }

    /// The thread's time constraint policy (with a priority field).
    /// - Warning: This uses a private policy flavor. Use at your own risk.
    public var timeConstraintWithPriorityPolicy: Mach.ThreadTimeConstraintWithPriorityPolicy {
        get throws { try self.getPolicy(THREAD_TIME_CONSTRAINT_WITH_PRIORITY_POLICY) }
    }

    /// Sets the thread's time constraint policy (with a priority field).
    /// - Warning: This uses a private policy flavor. Use at your own risk.
    public func setTimeConstraintWithPriorityPolicy(
        _ timeConstraintWithPriorityPolicy: Mach.ThreadTimeConstraintWithPriorityPolicy
    ) throws {
        try self.setPolicy(
            THREAD_TIME_CONSTRAINT_WITH_PRIORITY_POLICY, to: timeConstraintWithPriorityPolicy)
    }

    /// The thread's requested QoS policy.
    /// - Warning: This uses a private policy flavor. Use at your own risk.
    public var requestedQoSPolicy: Mach.ThreadRequestedQoSPolicy {
        get throws { try self.getPolicy(THREAD_REQUESTED_STATE_POLICY) }
    }
}
