/*
 * Portions Copyright (c) 2000-2005 Apple Computer, Inc. All rights reserved.
 *
 * The flavor values for these infos are not included in the
 * header files. They are taken from the XNU source code.
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

private let PROCESSOR_SET_ENABLED_POLICIES: Int32 = 3
private let PROCESSOR_SET_TIMESHARE_DEFAULT: Int32 = 10
private let PROCESSOR_SET_TIMESHARE_LIMITS: Int32 = 11

private let PROCESSOR_SET_RR_DEFAULT: Int32 = 20
private let PROCESSOR_SET_RR_LIMITS: Int32 = 21

private let PROCESSOR_SET_FIFO_DEFAULT: Int32 = 30
private let PROCESSOR_SET_FIFO_LIMITS: Int32 = 31

extension Mach.ProcessorSetInfoFlavor {
    /// The enabled policies for a processor set.
    public static let enabledPolicies = Self(rawValue: PROCESSOR_SET_ENABLED_POLICIES)

    /// The default timeshare policy for a processor set.
    public static let timeshareDefault = Self(rawValue: PROCESSOR_SET_TIMESHARE_DEFAULT)

    /// The limits for the timeshare policy in a processor set.
    public static let timeshareLimits = Self(rawValue: PROCESSOR_SET_TIMESHARE_LIMITS)

    /// The default round robin policy for a processor set.
    public static let roundRobinDefault = Self(rawValue: PROCESSOR_SET_RR_DEFAULT)

    /// The limits for the round robin policy in a processor set.
    public static let roundRobinLimits = Self(rawValue: PROCESSOR_SET_RR_LIMITS)

    /// The default FIFO policy for a processor set.
    public static let fifoDefault = Self(rawValue: PROCESSOR_SET_FIFO_DEFAULT)

    /// The limits for the FIFO policy in a processor set.
    public static let fifoLimits = Self(rawValue: PROCESSOR_SET_FIFO_LIMITS)
}

extension Mach.ProcessorSetInfoManager {
    /// The enabled policies for the processor set.
    public var enabledPolicies: policy_t {
        get throws { try self.get(.enabledPolicies) }
    }

    /// The default timeshare policy for the processor set.
    public var defaultTimesharePolicy: policy_timeshare_base {
        get throws { try self.get(.timeshareDefault) }
    }

    /// The limits for the timeshare policy in the processor set.
    public var timesharePolicyLimits: policy_timeshare_limit {
        get throws { try self.get(.timeshareLimits) }
    }

    /// The default round robin policy for the processor set.
    public var defaultRoundRobinPolicy: policy_rr_base {
        get throws { try self.get(.roundRobinDefault) }
    }

    /// The limits for the round robin policy in the processor set.
    public var roundRobinPolicyLimits: policy_rr_limit {
        get throws { try self.get(.roundRobinLimits) }
    }

    /// The default FIFO policy for the processor set.
    public var defaultFIFOPolicy: policy_fifo_base {
        get throws { try self.get(.fifoDefault) }
    }

    /// The limits for the FIFO policy in the processor set.
    public var fifoPolicyLimits: policy_fifo_limit {
        get throws { try self.get(.fifoLimits) }
    }
}
