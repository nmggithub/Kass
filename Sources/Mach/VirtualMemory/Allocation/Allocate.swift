/*
 * Portions Copyright (c) 2000-2020 Apple Inc. All rights reserved.
 *
 * The main difference between this file and the original file is that the original file is written in C, while this file is written in Swift.
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
 * @OSF_COPYRIGHT@
 */
/*
 * Mach Operating System
 * Copyright (c) 1991,1990,1989,1988,1987 Carnegie Mellon University
 * All Rights Reserved.
 *
 * Permission to use, copy, modify and distribute this software and its
 * documentation is hereby granted, provided that both the copyright
 * notice and this permission notice appear in all copies of the
 * software, derivative works or modified versions, and any portions
 * thereof, and that both notices appear in supporting documentation.
 *
 * CARNEGIE MELLON ALLOWS FREE USE OF THIS SOFTWARE IN ITS "AS IS"
 * CONDITION.  CARNEGIE MELLON DISCLAIMS ANY LIABILITY OF ANY KIND FOR
 * ANY DAMAGES WHATSOEVER RESULTING FROM THE USE OF THIS SOFTWARE.
 *
 * Carnegie Mellon requests users of this software to return to
 *
 *  Software Distribution Coordinator  or  Software.Distribution@CS.CMU.EDU
 *  School of Computer Science
 *  Carnegie Mellon University
 *  Pittsburgh PA 15213-3890
 *
 * any improvements or extensions that they make and grant Carnegie Mellon
 * the rights to redistribute these changes.
 */
/*
 */
/*
 *	File:	mach/vm_statistics.h
 *	Author:	Avadis Tevanian, Jr., Michael Wayne Young, David Golub
 *
 *	Virtual memory statistics structure.
 *
 */

import CCompat
import Darwin.Mach

extension Mach.VM {
    /// - Warning: This work is covered under license. Please view the source code and <doc:MachVM#Licenses> for more information.
    public enum AllocationFlag: Int32 {
        /// Allocate new VM region at the specified virtual address, if possible.
        case fixed = 0x0000_0000
        /// Allocate new VM region anywhere it would fit in the address space.
        case anywhere = 0x0000_0001
        /// Create a purgable VM object for that new VM region.
        /// - Note: The apparent typo is copied from the original source.
        case purgable = 0x0000_0002
        /// The new VM region will be chunked up into 4GB sized pieces.
        /// - Note: Case names cannot start with a number, so the number is spelled out.
        case fourGBChunk = 0x0000_0004
        case randomAddress = 0x0000_0008
        case noCache = 0x0000_0010
        case resilientCodesign = 0x0000_0020
        case resilientMedia = 0x0000_0040
        case permanent = 0x0000_0080
        case trpo = 0x0000_0100
        /// The new VM region can replace existing VM regions if necessary
        /// (to be used in combination with VM_FLAGS_FIXED).
        case overwrite = 0x0000_0200
    }
    /// Allocate a new VM region in the task's address space.
    /// - Parameters:
    ///   - task: The task that will own the memory region.
    ///   - address: The base address of the new VM region.
    ///   - size: The size of the new VM region.
    ///   - flags: The flags that control the allocation.
    /// - Throws: An error if the operation fails.
    public static func allocate(
        task: Mach.Task = .current,
        address: inout vm_address_t, size: vm_size_t,
        flags: Set<Mach.VM.AllocationFlag> = []
    ) throws {
        try Mach.call(
            vm_allocate(task.name, &address, size, flags.bitmap())
        )
    }
}
