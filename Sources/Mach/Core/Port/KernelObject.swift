/*
 * Portions Copyright (c) 2000-2006 Apple Computer, Inc. All rights reserved.
 *
 * The `KernelObjectType` enumeration is taken from the XNU source code.
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
/*
 *	File:	kern/ipc_kobject.h
 *	Author:	Rich Draves
 *	Date:	1989
 *
 *	Declarations for letting a port represent a kernel object.
 */

import Darwin.Mach

extension Mach {
    /// A type of kernel object.
    /// - Warning: This work is covered under license. Please view the source code and <doc:MachCore#Licenses> for more information.
    public enum KernelObjectType: natural_t {
        /// There is no kernel object.
        case none = 0

        /// The port is a thread control port.
        case threadControl = 1

        /// The port is a task control port.
        case taskControl = 2

        /// The port is a host control port.
        case host = 3

        /// The port is a privileged host port.
        case hostPriv = 4

        /// A processor.
        case processor = 5

        /// The port is a processor set control port.
        case pset = 6

        /// The port is a processor set name port.
        case psetName = 7

        /// A timer.
        case timer = 8

        /// The port is a substitute-once port.
        case substituteOnce = 9

        /// A MIG object.
        @available(macOS, obsoleted: 12.0.1)
        case mig = 10

        /// A memory object.
        case memoryObject = 11

        // It's unclear what these even are/were, or if they were ever used. But they definitely aren't used now.

        @available(macOS, unavailable)
        case xmmPager = 12
        @available(macOS, unavailable)
        case xmmKernel = 13
        @available(macOS, unavailable)
        case xmmReply = 14

        /// A user-notification daemon reply.
        case undReply = 15

        /// The port is a host notification port.
        @available(macOS, obsoleted: 13.0)
        case hostNotify = 16

        /// The port is a host security port.
        @available(macOS, obsoleted: 12.0.1)
        case hostSecurity = 17

        /// A ledger.
        @available(macOS, obsoleted: 12.0.1)
        case ledger = 18

        /// An IOKit main device service.
        case mainDevice = 19

        /// The port is a task name port.
        case taskName = 20

        /// A subsystem.
        @available(macOS, unavailable)
        case subsystem = 21

        @available(macOS, unavailable)
        case ioDoneQueue = 22

        /// A semaphore.
        case semaphore = 23

        /// A lock set.
        @available(macOS, unavailable)
        case lockSet = 24

        /// The port is a clock port.
        case clock = 25

        /// The port is a clock control port.
        @available(macOS, obsoleted: 13.0)
        case clockCtrl = 26

        /// An IOKit server check-in token.
        case iokitIdent = 27

        /// A memory entry.
        case memoryEntry = 28

        /// An IOKit connection.
        case iokitConnect = 29

        /// An IOKit object.
        case iokitObject = 30

        /// A universal page list.
        @available(macOS, obsoleted: 12.0.1)
        case upl = 31

        /// The port is a memory object control port.
        /// - Note: Technically, this kernel object type existed in macOS 12.0.1, but it was only used in one check. That check specifically
        /// would intentionally kernel panic if it encountered this type, so it's safe to say that this type was obsoleted in macOS 12.0.1.
        @available(macOS, obsoleted: 12.0.1)
        case memObjControl = 32

        /// An audit session.
        case auditSession = 33

        /// A fileport (file descriptor).
        case fileport = 34

        /// A task resume token.
        case taskResume = 36

        /// A voucher.
        case voucher = 37

        /// The port is a voucher attribute control port.
        @available(macOS, obsoleted: 13)
        case voucherAttrControl = 38

        /// A work interval.
        case workInterval = 39

        /// A user exception handler.
        case uxHandler = 40

        /// An OSObject used in IOKit.
        case uextObject = 41

        /// A register for Apple Arcade.
        case arcadeRegister = 42

        /// An eventlink.
        case eventlink = 43

        /// The port is a task inspect port.
        case taskInspect = 44

        /// The port is a task read port.
        case taskRead = 45

        /// The port is a thread inspect port.
        case threadInspect = 46

        /// The port is a thread read port.
        case threadRead = 47

        /// A setuid credential.
        @available(macOS, obsoleted: 12.3)
        case setuidCredential = 48

        /// A hypervisor.
        case hypervisor = 49

        /// A task identity token.
        case taskIdToken = 50

        /// The port is a task fatal port.
        case taskFatal = 51

        /// Kernelcache data.
        case kcdata = 52

        /// An exclaves resource.
        case exclavesResource = 53

        /// The type of the kernel object is unknown.
        case unknown
    }
}

extension Mach {
    /// A kernel object underlying a port.
    public struct KernelObject {
        /// The type of the kernel object.
        public let type: Mach.KernelObjectType

        /// The address of the kernel object.
        /// - Warning: When using non-development kernel builds, this address may be zero.
        public let address: mach_vm_address_t

        /// A string describing the kernel object.
        public let description: String

        /// Gets the underlying kernel object for a port.
        public init(underlying port: Mach.Port) throws {
            var type = natural_t()
            var objectAddress = mach_vm_address_t()
            let descriptionPointer = UnsafeMutablePointer<CChar>.allocate(
                capacity: Int(KOBJECT_DESCRIPTION_LENGTH)
            )
            try Mach.call(
                mach_port_kobject_description(
                    port.owningTask.name, port.name, &type, &objectAddress, descriptionPointer
                )
            )
            self.type = Mach.KernelObjectType(rawValue: type) ?? .unknown
            self.address = objectAddress
            self.description = String(cString: descriptionPointer)
        }
    }
}
