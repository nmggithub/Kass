/*
 * Portions Copyright (c) 2000-2015 Apple Inc. All rights reserved.
 *
 * The `HostDebugInfoInternal` struct is taken from the XNU kernel's `osfmk/mach/host_info.h` header.
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

extension Mach.HostInfoFlavor {
    /// Debug info about a host.
    public static let debugInfo = Self(rawValue: HOST_DEBUG_INFO_INTERNAL)
}

extension Mach {
    /// Debug information about the host.
    /// - Warning: This work is covered under license. Please view the source code and <doc:MachCore#Licenses> for more information.
    public struct HostDebugInfoInternal: BitwiseCopyable {
        private let _config: UInt64  // the configuration bitfield

        public var config_bank: Bool { _config & 1 != 0 }
        public var config_atm: Bool { (_config & (1 << 1)) != 0 }
        public var config_csr: Bool { (_config & (1 << 2)) != 0 }
        public var config_coalitions: Bool { (_config & (1 << 3)) != 0 }
        public var config_unused: UInt64 { _config >> 4 }  // clear the first 4 bits, which are used above
    }
}

extension Mach.HostInfoManager {
    /// The debug info of the host.
    /// - Warning: This is only supported on development or debug kernels.
    public var debugInfo: Mach.HostDebugInfoInternal { get throws { try self.get(.debugInfo) } }
}
