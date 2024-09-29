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

extension Mach {
    /// A task's suppression policy.
    /// - Warning: This work is covered under license. Please view the source code and <doc:MachCore#Licenses> for more information.
    public struct TaskSuppressionPolicy: BitwiseCopyable {
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

    /// A task's policy state.
    /// - Warning: This work is covered under license. Please view the source code and <doc:MachCore#Licenses> for more information.
    public struct TaskPolicyState: BitwiseCopyable {
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
}

extension Mach.Task {
    /// The task's suppression policy.
    public var suppressionPolicy: Mach.TaskSuppressionPolicy {
        get throws { try self.getPolicy(.suppression) }
    }

    /// Set's the task's suppression policy.
    public func setSuppressionPolicy(_ suppressionPolicy: Mach.TaskSuppressionPolicy) throws {
        try self.setPolicy(.suppression, to: suppressionPolicy)
    }

    /// The task's policy state.
    /// - Important: Only privileged tasks can get this.
    public var policyState: Mach.TaskPolicyState {
        get throws { try self.getPolicy(.state) }
    }
}
