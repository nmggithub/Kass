/*
 * Portions Copyright (c) 2004-2007 Apple Inc. All rights reserved.
 *
 * The state structure definitions are also taken from the XNU source code.
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

// The C structs `arm_neon_state32_t` and `arm_neon_state64_t` should be available Swift. However, they make use of
// `__uint128_t`, which was only recently added to Swift. They also don't appear to be bridged properly, so they're
// currently unusable for the purposes of this library. As a temporary solution, we'll define our own types here.
//
// Issue: https://github.com/swiftlang/swift/issues/76758

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

#if arch(arm64)  // XNU makes the original structs opaque for `arm`, so we'll just ignore implementing this for `arm`.
    @available(macOS 15, *)  // UInt128 is only available on macOS 15.0 and later.
    extension Mach.Thread {
        /// An ARM NEON state of a thread (32-bit).
        /// - Important: This is a temporary substitute for `arm_neon_state32_t`. Please see
        ///  the source code for more information.
        /// - Warning: This work is covered under license. Please view the source code and <doc:MachCore#Licenses> for more information.
        public struct ARMNEONState32: BitwiseCopyable {
            #if __DARWIN_UNIX03
                public let __v:
                    (
                        UInt128, UInt128, UInt128, UInt128, UInt128, UInt128, UInt128, UInt128,
                        UInt128, UInt128, UInt128, UInt128, UInt128, UInt128, UInt128, UInt128
                    )
                private let padding: (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8)
                public let __fpsr: UInt32
                public let __fpcr: UInt32
            #else  // member names are different
                public let q:
                    (
                        UInt128, UInt128, UInt128, UInt128, UInt128, UInt128, UInt128, UInt128,
                        UInt128, UInt128, UInt128, UInt128, UInt128, UInt128, UInt128, UInt128
                    )
                private let padding: (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8)
                public let fpsr: UInt32
                public let fpcr: UInt32
            #endif
        }
        /// An ARM NEON state of a thread (64-bit).
        /// - Important: This is a temporary substitute for `arm_neon_state64_t`. Please see
        /// the source code for more information.
        /// - Warning: This work is covered under license. Please view the source code and <doc:MachCore#Licenses> for more information.
        public struct ARMNEONState64: BitwiseCopyable {
            #if __DARWIN_UNIX03
                public let __v:
                    (
                        UInt128, UInt128, UInt128, UInt128, UInt128, UInt128, UInt128, UInt128,
                        UInt128, UInt128, UInt128, UInt128, UInt128, UInt128, UInt128, UInt128,
                        UInt128, UInt128, UInt128, UInt128, UInt128, UInt128, UInt128, UInt128,
                        UInt128, UInt128, UInt128, UInt128, UInt128, UInt128, UInt128, UInt128
                    )
                private let padding: (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8)
                public let __fpsr: UInt32
                public let __fpcr: UInt32
            #else  //  member names are different
                public let q:
                    (
                        UInt128, UInt128, UInt128, UInt128, UInt128, UInt128, UInt128, UInt128,
                        UInt128, UInt128, UInt128, UInt128, UInt128, UInt128, UInt128, UInt128,
                        UInt128, UInt128, UInt128, UInt128, UInt128, UInt128, UInt128, UInt128,
                        UInt128, UInt128, UInt128, UInt128, UInt128, UInt128, UInt128, UInt128
                    )
                private let padding: (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8)
                public let fpsr: UInt32
                public let fpcr: UInt32
            #endif
        }
    }

    @available(macOS 15, *)  // UInt128 is only available on macOS 15.0 and later.
    extension Mach.Thread {
        /// The ARM NEON state of the thread (32-bit).
        /// - Important: This return type a temporary substitute for `arm_neon_state32_t`. Please see
        ///  the source code for more information.
        public var armNEONState32: Mach.Thread.ARMNEONState32 {
            get throws { try self.getState(ARM_NEON_STATE) }
        }

        /// The ARM NEON state of the thread (64-bit).
        /// - Important: This return type a temporary substitute for `arm_neon_state64_t`. Please see
        /// the source code for more information.
        public var armNEONState64: Mach.Thread.ARMNEONState64 {
            get throws { try self.getState(ARM_NEON_STATE64) }
        }
    }
#endif
