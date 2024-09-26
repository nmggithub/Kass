/*
 * Portions Copyright (c) 2000-2005 Apple Computer, Inc. All rights reserved.
 *
 * The `SuppressionPolicy` and `PolicyState` structs are copied from the `task_suppression_policy` and
 * `task_policy_state` structs (respectively) from the XNU source code.
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

extension Mach {
    /// A type of task policy.
    public enum TaskPolicy: task_policy_flavor_t {
        case category = 1
        case suppression = 3
        case state = 4
        case baseQoS = 8
        case overrideQoS = 9
        case latencyQoS = 10
        case throughputQoS = 11
    }
}

extension Mach.Task {
    /// Gets the task's policy.
    public func getPolicy<DataType: BitwiseCopyable>(
        _ policy: Mach.TaskPolicy, as type: DataType.Type = DataType.self
    ) throws -> DataType {
        try Mach.callWithCountInOut(type: type) {
            (array: task_policy_t, count) in
            var dontGetDefault = boolean_t(0)
            return task_policy_get(self.name, policy.rawValue, array, &count, &dontGetDefault)
        }
    }

    /// Sets the task's policy.
    public func setPolicy<DataType: BitwiseCopyable>(
        _ policy: Mach.TaskPolicy, to value: DataType
    ) throws {
        try Mach.callWithCountIn(value: value) {
            (array: task_policy_t, count) in
            task_policy_set(self.name, policy.rawValue, array, count)
        }
    }
}

extension Mach.TaskPolicy {
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

    /// A task's suppression policy.
    /// - Warning: This work is covered under license. Please view the source code and <doc:MachCore#Licenses> for more information.
    public struct SuppressionPolicy: BitwiseCopyable {
        let active: Int32
        let lowpri_cpu: Int32
        let timer_throttle: Int32
        let disk_throttle: Int32
        let cpu_limit: Int32
        let suspend: Int32
        let throughput_qos: Int32
        let suppressed_cpu: Int32
        let background_sockets: Int32
        let reserved1: Int32
        let reserved2: Int32
        let reserved3: Int32
        let reserved4: Int32
        let reserved5: Int32
        let reserved6: Int32
        let reserved7: Int32
    }

    /// The task's suppression policy.
    public var suppressionPolicy: SuppressionPolicy {
        get throws { try self.getPolicy(.suppression) }
    }

    /// Set's the task's suppression policy.
    public func setSuppressionPolicy(_ suppressionPolicy: SuppressionPolicy) throws {
        try self.setPolicy(.suppression, to: suppressionPolicy)
    }

    /// A task's policy state.
    /// - Warning: This work is covered under license. Please view the source code and <doc:MachCore#Licenses> for more information.
    public struct PolicyState: BitwiseCopyable {
        let requested: UInt64
        let effective: UInt64
        let pending: UInt64
        let imp_assertcnt: UInt32
        let imp_externcnt: UInt32
        let flags: UInt64
        let imp_transitions: UInt64
        let tps_requested_policy: UInt64
        let tps_effective_policy: UInt64
    }

    /// The task's policy state.
    /// - Important: Only privileged tasks can get this.
    public var policyState: PolicyState {
        get throws { try self.getPolicy(.state) }
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
