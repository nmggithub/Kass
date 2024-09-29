/*
 * Portions Copyright (c) 2000-2020 Apple Inc. All rights reserved.
 *
 * The structures and flavor values for these states are not included in
 * the public header files. They are taken from the XNU source code.
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
 * Mach Operating System
 * Copyright (c) 1991,1990,1989 Carnegie Mellon University
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

import Darwin.Mach

private let x86_SAVED_STATE32: thread_state_flavor_t = THREAD_STATE_NONE + 1
private let x86_SAVED_STATE64: thread_state_flavor_t = THREAD_STATE_NONE + 2

/// Helpers for getting and setting the thread's state for cases not covered by the `ThreadState` enum.
extension Mach.Thread {
    /// Gets the thread's state using a raw state flavor.
    fileprivate func getState<DataType: BitwiseCopyable>(
        _ state: thread_state_flavor_t, as type: DataType.Type = DataType.self
    ) throws -> DataType {
        try Mach.callWithCountInOut(type: type) {
            (array: thread_state_t, count) in
            thread_get_state(self.name, state, array, &count)
        }
    }

    /// Sets the thread's state using a raw state flavor.
    fileprivate func setState<DataType: BitwiseCopyable>(
        _ state: thread_state_flavor_t, to value: DataType
    ) throws {
        try Mach.callWithCountIn(value: value) {
            (array: thread_state_t, count) in
            thread_set_state(self.name, state, array, count)
        }
    }
}

#if arch(i386) || arch(x86_64)
    extension Mach.Thread {
        /// A 32-bit x86 saved state.
        /// - Warning: This work is covered under license. Please view the source code and <doc:MachCore#Licenses> for more information.
        public struct X86SavedState32: BitwiseCopyable {
            public let gs: UInt32
            public let fs: UInt32
            public let es: UInt32
            public let ds: UInt32
            public let edi: UInt32
            public let esi: UInt32
            public let ebp: UInt32
            public let cr2: UInt32
            public let ebx: UInt32
            public let edx: UInt32
            public let ecx: UInt32
            public let eax: UInt32
            public let trapno: UInt16
            public let cpu: UInt16
            public let err: UInt32
            public let eip: UInt32
            public let cs: UInt32
            public let efl: UInt32
            public let uesp: UInt32
            public let ss: UInt32
        }

        /// A 64-bit x86 interrupt stack frame.
        /// - Warning: This work is covered under license. Please view the source code and <doc:MachCore#Licenses> for more information.
        public struct x86_64InterruptStackFrame: BitwiseCopyable {
            public let trapno: UInt16
            public let cpu: UInt16
            public let _pad: UInt32
            public let trapfn: UInt64
            public let err: UInt64
            public let rip: UInt64
            public let cs: UInt64
            public let rflags: UInt64
            public let rsp: UInt64
            public let ss: UInt64
        }

        /// A 64-bit x86 saved state.
        /// - Warning: This work is covered under license. Please view the source code and <doc:MachCore#Licenses> for more information.
        public struct X86SavedState64: BitwiseCopyable {
            public let rdi: UInt64
            public let rsi: UInt64
            public let rdx: UInt64
            public let r10: UInt64
            public let r8: UInt64
            public let r9: UInt64
            public let cr2: UInt64
            public let r15: UInt64
            public let r14: UInt64
            public let r13: UInt64
            public let r12: UInt64
            public let r11: UInt64
            public let rbp: UInt64
            public let rbx: UInt64
            public let rcx: UInt64
            public let rax: UInt64
            public let gs: UInt32
            public let fs: UInt32
            public let ds: UInt32
            public let es: UInt32
            public let isf: x86_64InterruptStackFrame
        }
    }

    extension Mach.Thread {
        /// The 32-bit x86 saved state of the thread.
        public var x86SavedState32: X86SavedState32 {
            get throws { try self.getState(x86_SAVED_STATE32) }
        }

        /// The 64-bit x86 saved state of the thread.
        public var x86SavedState64: X86SavedState64 {
            get throws { try self.getState(x86_SAVED_STATE64) }
        }
    }

    extension Mach.Thread {
        #if arch(i386)
            /// The saved state of the thread (32-bit).
            public var savedState: X86SavedState32 {
                get throws { try self.x86SavedState32 }
            }
        #elseif arch(x86_64)
            /// The saved state of the thread (64-bit).
            public var savedState: X86SavedState64 {
                get throws { try self.x86SavedState64 }
            }
        #endif
    }
#endif
