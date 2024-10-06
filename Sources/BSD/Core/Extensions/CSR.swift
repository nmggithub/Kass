/*
 * Portions Copyright (c) 2014 Apple Inc. All rights reserved.
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

import CCompat
import Linking

private let csr_check: @convention(c) (UInt32) -> Int32 = libSystem().get(symbol: "csr_check")!
    .cast()
private let csr_get_active_config: @convention(c) (UnsafeMutablePointer<UInt32>) -> Int32 =
    libSystem().get(symbol: "csr_get_active_config")!.cast()

extension BSD {
    /// Configurable Security Restrictions.
    /// - Important: This is more commonly known as System Integrity Protection (SIP).
    /// - Warning: This work is covered under license. Please view the source code and <doc:BSDBase#Licenses> for more information.
    public struct CSR: Namespace {
        /// A configuration option for CSR.
        public enum ConfigOption: UInt32, CaseIterable {
            case allowUntrustedKexts = 1
            case allowUnrestrictedFS = 2
            case allowTaskForPid = 4
            case allowKernelDebugger = 8
            case allowAppleInternal = 16
            case allowUnrestrictedDTrace = 32
            case allowUnrestrictedNVRAM = 64
            case allowDeviceConfiguration = 128
            case allowAnyRecoveryOS = 256
            case allowUnapprovedKexts = 512
            case allowExecutionPolicyOverride = 1024
            case allowUnauthenticatedRoot = 2048
        }
        /// Checks a set of options.
        /// - Parameter options: The options to check.
        /// - Throws: An error if the options are not all in the active configuration.
        public static func check(_ options: Set<ConfigOption>) throws {
            let flags = options.bitmap()
            try BSD.syscall(csr_check(flags))
        }
        /// The active configuration.
        public static var activeConfig: Set<ConfigOption> {
            get throws {
                var flags: UInt32 = 0
                try BSD.syscall(csr_get_active_config(&flags))
                return Set(ConfigOption.set(from: flags))
            }
        }
    }
}
