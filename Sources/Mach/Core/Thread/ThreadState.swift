/*
 * Portions Copyright (c) 2007 Apple Inc. All rights reserved.
 * Original file: osfmk/mach/arm/thread_status.h
 *
 * The list of ARM state types is taken from the XNU source code.
 *
 * Portions Copyright (c) 2000-2020 Apple Inc. All rights reserved.
 * Original file: osfmk/mach/i386/thread_status.h
 *
 * The list of x86 state types is taken from the XNU source code.
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

extension Mach {
    /// A type of thread state.
    /// - Warning: This work is covered under license. Please view the source code and <doc:MachCore#Licenses> for more information.
    public enum ThreadState: thread_state_flavor_t {
        #if arch(arm) || arch(arm64)
            /// ARM VFP state.
            case armVFP = 2

            /// 32-bit ARM exception state.
            case armException32 = 3

            /// Legacy (pre-Armv8) 32-bit ARM debug state.
            case armDebugLegacy = 4

            case none = 5  // a special case

            /// 64-bit ARM state.
            case arm64 = 6

            /// 64-bit ARM exception state.
            case armException64 = 7

            /// 32-bit ARM state.
            case arm32 = 8

            /// 32-bit ARM debug state.
            case armDebug32 = 14

            /// 64-bit ARM debug state.
            case armDebug64 = 15

            /// ARM page-in state.
            case armPageIn = 27
        #elseif arch(i386) || arch(x86_64)
            /// 32-bit x86 state.
            case x86_32 = 1

            /// 32-bit x86 floating-point state.
            case x86Float32 = 2

            /// 32-bit x86 exception state.
            case x86Exception32 = 3

            /// 64-bit x86 state.
            case x86_64 = 4

            /// 64-bit x86 floating-point state.
            case x86Float64 = 5

            /// 64-bit x86 exception state.
            case x86Exception64 = 6

            /// 32-bit x86 debug state.
            case x86Debug32 = 10

            /// 64-bit x86 debug state.
            case x86Debug64 = 11

            case none = 13  // a special case

            /// 32-bit x86 AVX state.
            case x86AVX32 = 16

            /// 64-bit x86 AVX state.
            case x86AVX64  // +1

            /// x86 page-in state.
            case x86PageIn = 22

            /// The full 64-bit x86 state.
            case x86Full64 = 23

            /// x86 instruction state.
            case x86Instruction = 24

            /// x86 last branch record state.
            case x86LastBranch = 25
        #endif
    }
}

extension Mach.Thread {
    /// Gets the thread's state.
    public func getState<StateDataType: BitwiseCopyable>(
        _ state: Mach.ThreadState, as type: StateDataType.Type = StateDataType.self
    ) throws -> StateDataType {
        try Mach.callWithCountInOut(type: type) {
            (array: thread_state_t, count) in
            thread_get_state(self.name, state.rawValue, array, &count)
        }
    }

    /// Sets the thread's state.
    public func setState(
        _ state: Mach.ThreadState, to value: BitwiseCopyable
    ) throws {
        try Mach.callWithCountIn(value: value) {
            (array: thread_state_t, count) in
            thread_set_state(self.name, state.rawValue, array, count)
        }
    }
}

extension Mach.ThreadState {
    /// Gets the state for a thread.
    public func get<StateDataType: BitwiseCopyable>(
        as type: StateDataType.Type, for thread: Mach.Thread = .current
    ) throws -> StateDataType { try thread.getState(self, as: type) }

    /// Sets the state for a thread.
    public func set(
        to value: BitwiseCopyable, for thread: Mach.Thread = .current
    ) throws { try thread.setState(self, to: value) }
}

#if arch(arm) || arch(arm64)
    extension Mach.Thread {
        // General states

        /// The ARM state of the thread (32-bit).
        public var armState32: arm_thread_state32_t {
            get throws { try self.getState(.arm32) }
        }

        /// The ARM state of the thread (64-bit).
        public var armState64: arm_thread_state64_t {
            get throws { try self.getState(.arm64) }
        }

        // Exception states

        /// The ARM exception state of the thread (32-bit).
        public var armExceptionState32: arm_exception_state32_t {
            get throws { try self.getState(.armException32) }
        }

        /// The ARM exception state of the thread (64-bit).
        public var armExceptionState64: arm_exception_state64_t {
            get throws { try self.getState(.armException64) }
        }

        // Debug states

        /// The ARM debug state of the thread (32-bit).
        public var armDebugState32: arm_debug_state32_t {
            get throws { try self.getState(.armDebug32) }
        }

        /// The legacy (pre-Armv8) ARM debug state of the thread (32-bit).
        public var armDebugState32Legacy: arm_debug_state_t {
            get throws { try self.getState(.armDebugLegacy) }
        }

        /// The ARM debug state of the thread (64-bit).
        public var armDebugState64: arm_debug_state64_t {
            get throws { try self.getState(.armDebug64) }
        }

        /// Non-bit-width-specific states

        /// The ARM page-in state of the thread.
        public var armPageInState: arm_pagein_state_t {
            get throws { try self.getState(.armPageIn) }
        }

        /// The ARM VFP state of the thread.
        public var armVFPState: arm_vfp_state_t {
            get throws { try self.getState(.armVFP) }
        }

    }
#elseif arch(i386) || arch(x86_64)
    extension Mach.Thread {
        // General states

        /// The x86 state of the thread (32-bit).
        public var x86State32: x86_thread_state32_t {
            get throws { try self.getState(.x86_32) }
        }

        /// The x86 state of the thread (64-bit).
        public var x86State64: x86_thread_state64_t {
            get throws { try self.getState(.x86_64) }
        }

        /// The full 64-bit x86 state of the thread.
        public var x86FullState64: x86_thread_full_state64_t {
            get throws { try self.getState(.x86Full64) }
        }

        // Exception states

        /// The x86 exception state of the thread (32-bit).
        public var x86ExceptionState32: x86_exception_state32_t {
            get throws { try self.getState(.x86Exception32) }
        }

        /// The x86 exception state of the thread (64-bit).
        public var x86ExceptionState64: x86_exception_state64_t {
            get throws { try self.getState(.x86Exception64) }
        }

        // Debug states

        /// The x86 debug state of the thread (32-bit).
        public var x86DebugState32: x86_debug_state32_t {
            get throws { try self.getState(.x86Debug32) }
        }

        /// The x86 debug state of the thread (64-bit).
        public var x86DebugState64: x86_debug_state64_t {
            get throws { try self.getState(.x86Debug64) }
        }

        // FIXME: Floating-point state structs are not properly bridged for x86 (or rather, they
        // don't conform to `BitwiseCopyable`, which is an indication that they are not properly
        // bridged).
        // // Floating-point states

        // /// The 32-bit x86 floating-point state of the thread.
        // public var x86FloatState32: x86_float_state32_t {
        //     get throws { try self.getState(.x86Float32) }
        // }

        // /// The 64-bit x86 floating-point state of the thread.
        // public var x86FloatState64: x86_float_state64_t {
        //     get throws { try self.getState(.x86Float64) }
        // }

        // FIXME: x86 AVX state structs are not properly bridged (or rather, they don't conform
        // to `BitwiseCopyable`, which is an indication that they are not properly bridged).
        // // AVX states

        // /// The x86 debug AVX of the thread (32-bit).
        // public var x86AVXState32: x86_avx_state32_t {
        //     get throws { try self.getState(.x86AVX32) }
        // }

        // /// The x86 debug AVX of the thread (64-bit).
        // public var x86AVXState64: x86_avx_state64_t {
        //     get throws { try self.getState(.x86AVX64) }
        // }

        // Non-bit-width-specific states

        /// The x86 page-in state of the thread.
        public var x86PageInState: x86_pagein_state_t {
            get throws { try self.getState(.x86PageIn) }
        }

        /// The x86 instruction state of the thread.
        public var x86InstructionState: x86_instruction_state_t {
            get throws { try self.getState(.x86Instruction) }
        }

        // FIXME: The `x86_last_branch_state_t` type cannot be found when building
        // for x86_64. Also, the underlying `__last_branch_state` structure is not
        // bridged properly (or rather, it doesn't conform to `BitwiseCopyable`).
        // /// The x86 last branch record state of the thread.
        // public var x86LastBranchState: x86_last_branch_state_t {
        //     get throws { try self.getState(.x86LastBranch) }
        // }
    }
#endif

/// Helper state properties
extension Mach.Thread {

    #if arch(arm)
        /// The general state of the thread.
        /// - Warning: The type of this property depends on the targeted architecture. Please see the
        /// source code for more information, or use one of the more explicitly named properties.
        public var generalState: arm_thread_state32_t {
            get throws { try self.armState32 }
        }
    #elseif arch(arm64)
        /// The general state of the thread.
        /// - Warning: The type of this property depends on the targeted architecture. Please see the
        /// source code for more information, or use one of the more explicitly named properties.
        public var generalState: arm_thread_state64_t {
            get throws { try self.armState64 }
        }
    #elseif arch(i386)
        /// The general state of the thread.
        /// - Warning: The type of this property depends on the targeted architecture. Please see the
        /// source code for more information, or use one of the more explicitly named properties.
        public var generalState: x86_thread_state32_t {
            get throws { try self.x86State32 }
        }
    #elseif arch(x86_64)
        /// The general state of the thread.
        /// - Warning: The type of this property depends on the targeted architecture. Please see the
        /// source code for more information, or use one of the more explicitly named properties.
        public var generalState: x86_thread_state64_t {
            get throws { try self.x86State64 }
        }
    #endif

    #if arch(arm)
        /// The exception state of the thread.
        /// - Warning: The type of this property depends on the targeted architecture. Please see the
        /// source code for more information, or use one of the more explicitly named properties.
        public var exceptionState: arm_exception_state32_t {
            get throws { try self.armExceptionState32 }
        }
    #elseif arch(arm64)
        /// The exception state of the thread.
        /// - Warning: The type of this property depends on the targeted architecture. Please see the
        /// source code for more information, or use one of the more explicitly named properties.
        public var exceptionState: arm_exception_state64_t {
            get throws { try self.armExceptionState64 }
        }
    #elseif arch(i386)
        /// The exception state of the thread.
        /// - Warning: The type of this property depends on the targeted architecture. Please see the
        /// source code for more information, or use one of the more explicitly named properties.
        public var exceptionState: x86_exception_state32_t {
            get throws { try self.x86ExceptionState32 }
        }
    #elseif arch(x86_64)
        /// The exception state of the thread.
        /// - Warning: The type of this property depends on the targeted architecture. Please see the
        /// source code for more information, or use one of the more explicitly named properties.
        public var exceptionState: x86_exception_state64_t {
            get throws { try self.x86ExceptionState64 }
        }
    #endif

    #if arch(arm)
        /// The debug state of the thread.
        /// - Warning: The type of this property depends on the targeted architecture. Please see the
        /// source code for more information, or use one of the more explicitly named properties.
        public var debugState: arm_debug_state32_t {
            get throws { try self.armDebugState32 }
        }
    #elseif arch(arm64)
        /// The debug state of the thread.
        /// - Warning: The type of this property depends on the targeted architecture. Please see the
        /// source code for more information, or use one of the more explicitly named properties.
        public var debugState: arm_debug_state64_t {
            get throws { try self.armDebugState64 }
        }
    #elseif arch(i386)
        /// The debug state of the thread.
        /// - Warning: The type of this property depends on the targeted architecture. Please see the
        /// source code for more information, or use one of the more explicitly named properties.
        public var debugState: x86_debug_state32_t {
            get throws { try self.x86DebugState32 }
        }
    #elseif arch(x86_64)
        /// The debug state of the thread.
        /// - Warning: The type of this property depends on the targeted architecture. Please see the
        /// source code for more information, or use one of the more explicitly named properties.
        public var debugState: x86_debug_state64_t {
            get throws { try self.x86DebugState64 }
        }
    #endif

    #if arch(arm) || arch(arm64)
        /// The floating-point state of the thread.
        /// - Warning: The type of this property depends on the targeted architecture. Please see the
        /// source code for more information, or use one of the more explicitly named properties.
        public var floatState: arm_vfp_state_t {
            get throws { try self.armVFPState }
        }
    // FIXME: Floating-point state structs are not properly bridged for x86 (or rather, they
    // don't conform to `BitwiseCopyable`, which is an indication that they are not properly
    // bridged).
    // #elseif arch(i386)
    //     /// The floating-point state of the thread.
    //     /// - Warning: The type of this property depends on the targeted architecture. Please see the
    //     /// source code for more information, or use one of the more explicitly named properties.
    //     public var floatState: x86_float_state32_t {
    //         get throws { try self.x86FloatState32 }
    //     }
    // #elseif arch(x86_64)
    //     /// The floating-point state of the thread.
    //     /// - Warning: The type of this property depends on the targeted architecture. Please see the
    //     /// source code for more information, or use one of the more explicitly named properties.
    //     public var floatState: x86_float_state64_t {
    //         get throws { try self.x86FloatState64 }
    //     }
    #endif

    // FIXME: x86 AVX state structs are not properly bridged (or rather, they don't conform
    // to `BitwiseCopyable`, which is an indication that they are not properly bridged).
    // #if arch(i386)
    //     /// The AVX state of the thread.
    //     /// - Warning: The type of this property depends on the targeted architecture. Please see the
    //     /// source code for more information, or use one of the more explicitly named properties.
    //     public var avxState: x86_avx_state32_t {
    //         get throws { try self.x86AVXState32 }
    //     }
    // #elseif arch(x86_64)
    //     /// The AVX state of the thread.
    //     /// - Warning: The type of this property depends on the targeted architecture. Please see the
    //     /// source code for more information, or use one of the more explicitly named properties.
    //     public var avxState: x86_avx_state64_t {
    //         get throws { try self.x86AVXState64 }
    //     }
    // #endif

    #if arch(arm) || arch(arm64)
        /// The page-in state of the thread.
        /// - Warning: The type of this property depends on the targeted architecture. Please see the
        /// source code for more information, or use one of the more explicitly named properties.
        public var pageInState: arm_pagein_state_t {
            get throws { try self.armPageInState }
        }
    #elseif arch(i386) || arch(x86_64)
        /// The page-in state of the thread.
        /// - Warning: The type of this property depends on the targeted architecture. Please see the
        /// source code for more information, or use one of the more explicitly named properties.
        public var pageInState: x86_pagein_state_t {
            get throws { try self.x86PageInState }
        }
    #endif
}
