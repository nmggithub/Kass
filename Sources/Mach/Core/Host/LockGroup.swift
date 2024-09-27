/*
 * Portions Copyright (c) 2004 Apple Computer, Inc. All rights reserved.
 *
 * The `LockGroup` structure is taken from the `lockgroup_info` structure.
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
/*
 *	File:	mach/lockgroup_info.h
 *
 *	Definitions for host_lockgroup_info call.
 */

import Darwin.Mach
import Foundation

extension Mach {
    /// A lock group.
    /// - Warning: This work is covered under license. Please view the source code and <doc:MachCore#Licenses> for more information.
    public struct LockGroup {
        internal let lockgroup_name:
            (
                CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar,
                CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar,
                CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar,
                CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar,
                CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar,
                CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar,
                CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar,
                CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar
            )
        public var name: String {
            withUnsafePointer(to: self.lockgroup_name) {
                pointer in
                return pointer.withMemoryRebound(
                    to: CChar.self, capacity: Int(LOCKGROUP_MAX_NAME)
                ) {
                    String(cString: $0)
                }
            }
        }
        public let lockgroup_attr: UInt64
        public let lock_spin_cnt: UInt64
        public let lock_spin_util_cnt: UInt64
        public let lock_spin_held_cnt: UInt64
        public let lock_spin_miss_cnt: UInt64
        public let lock_spin_held_max: UInt64
        public let lock_spin_held_cum: UInt64
        public let lock_mtx_cnt: UInt64
        public let lock_mtx_util_cnt: UInt64
        public let lock_mtx_held_cnt: UInt64
        public let lock_mtx_miss_cnt: UInt64
        public let lock_mtx_wait_cnt: UInt64
        public let lock_mtx_held_max: UInt64
        public let lock_mtx_held_cum: UInt64
        public let lock_mtx_wait_max: UInt64
        public let lock_mtx_wait_cum: UInt64
        public let lock_rw_cnt: UInt64
        public let lock_rw_util_cnt: UInt64
        public let lock_rw_held_cnt: UInt64
        public let lock_rw_miss_cnt: UInt64
        public let lock_rw_wait_cnt: UInt64
        public let lock_rw_held_max: UInt64
        public let lock_rw_held_cum: UInt64
        public let lock_rw_wait_max: UInt64
        public let lock_rw_wait_cum: UInt64
    }
}
extension Mach.Host {
    /// The lock groups in the host.
    public var lockGroups: [Mach.LockGroup] {
        get throws {
            var lockGroupInfo: lockgroup_info_array_t?
            var lockGroupCount = mach_msg_type_number_t.max
            try Mach.call(host_lockgroup_info(self.name, &lockGroupInfo, &lockGroupCount))
            return (0..<Int(lockGroupCount)).map {
                index in
                withUnsafePointer(to: &lockGroupInfo![index]) {
                    $0.withMemoryRebound(to: Mach.LockGroup.self, capacity: 1) { $0.pointee }
                }
            }
        }
    }
}
