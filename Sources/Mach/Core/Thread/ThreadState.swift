/*
 * Portions Copyright (c) 2007 Apple Inc. All rights reserved.
 *
 * The list of state types is taken from the XNU source code.
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
 * FILE_ID: thread_status.h
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
            case debug32 = 14

            /// 64-bit ARM debug state.
            case debug64 = 15

            /// ARM page-in state.
            case armPageIn = 27
        #elseif arch(i386) || arch(x86_64)
            case x86_32 = 1
            case x86Float32 = 2
            case x86Exception32 = 3
            case x86_64 = 4
            case x86Float64 = 5
            case x86Exception64 = 6
            case x86 = 7
            case x86Float = 8
            case x86Exception = 9
            case x86Debug32 = 10
            case x86Debug64 = 11
            case x86Debug = 12
            case none = 13

            // these both are an educated guess based on comments in the kernel
            case x86SavedState32 = 14
            case x86SavedState64 = 15

            case x86AVX32 = 16
            case x86AVX64  // +1
            case x86AVX  // +2
            case x86AVX512_32 = 19
            case x86AVX512_64  // +1
            case x86AVX512  // +2
            case x86PageIn = 22
            case x86Full = 23
            case x86Instruction = 24
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
        /// The 32-bit ARM state of the thread.
        public var arm32BitState: arm_thread_state32_t {
            get throws { try self.getState(.arm32) }
        }

        /// The 64-bit ARM state of the thread.
        public var arm64BitState: arm_thread_state64_t {
            get throws { try self.getState(.arm64) }
        }

        /// The ARM VFP state of the thread.
        public var armVFPState: arm_vfp_state_t {
            get throws { try self.getState(.armVFP) }
        }

        /// The 32-bit ARM exception state of the thread.
        public var arm32BitExceptionState: arm_exception_state32_t {
            get throws { try self.getState(.armException32) }
        }

        /// The 64-bit ARM exception state of the thread.
        public var arm64BitExceptionState: arm_exception_state64_t {
            get throws { try self.getState(.armException64) }
        }

        /// The legacy (pre-Armv8) 32-bit ARM debug state of the thread.
        public var arm32BitLegacyDebugState: arm_debug_state_t {
            get throws { try self.getState(.armDebugLegacy) }
        }

        /// The 32-bit debug state of the thread.
        public var arm32BitDebugState: arm_debug_state32_t {
            get throws { try self.getState(.debug32) }
        }

        /// The 64-bit debug state of the thread.
        public var arm64BitDebugState: arm_debug_state64_t {
            get throws { try self.getState(.debug64) }
        }

        /// The ARM page-in state of the thread.
        public var armPageInState: arm_pagein_state_t {
            get throws { try self.getState(.armPageIn) }
        }
    }
#elseif arch(i386) || arch(x86_64)

#endif
