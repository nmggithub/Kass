/*
 * Copyright (c) 2000-2002 Apple Computer, Inc. All rights reserved.
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
 *	File:	mach/thread_special_ports.h
 *
 *	Defines codes for special_purpose thread ports.  These are NOT
 *	port identifiers - they are only used for the thread_get_special_port
 *	and thread_set_special_port routines.
 *
 */

import Darwin.Mach

extension Mach {
    /// A special port for a thread.
    /// - Warning: This work is covered under license. Please view the source code and <doc:MachCore#Licenses> for more information.
    public enum ThreadSpecialPort: task_special_port_t, Mach.Port.SpecialPortType {
        /// The parent port type.
        public typealias ParentPort = Mach.Thread

        /// Gets a special port for the thread.
        public func get<PortType: Mach.Port>(
            for thread: Mach.Thread = .current, as type: PortType.Type = PortType.self
        ) throws -> PortType {
            try thread.getSpecialPort(self, as: type)
        }

        /// Sets a special port for the thread.
        public func set(for thread: Mach.Thread = .current, to port: Mach.Port) throws {
            try thread.setSpecialPort(self, to: port)
        }

        /// A thread's control port.
        case control = 1

        /// A thread's inspect port.
        case inspect = 2

        /// A thread's read port.
        case read = 3
    }
}

extension Mach.Thread: Mach.Port.WithSpecialPorts {
    /// Gets a special port for the thread.
    public func getSpecialPort<PortType: Mach.Port>(
        _ specialPort: Mach.ThreadSpecialPort, as type: PortType.Type = PortType.self
    ) throws -> PortType {
        var portName = mach_port_name_t()
        try Mach.call(
            thread_get_special_port(self.name, specialPort.rawValue, &portName)
        )
        return PortType(named: portName)
    }

    /// Sets a special port for the thread.
    public func setSpecialPort(_ specialPort: Mach.ThreadSpecialPort, to port: Mach.Port) throws {
        try Mach.call(
            thread_set_special_port(self.name, specialPort.rawValue, port.name)
        )
    }
}

extension Mach.Thread {
    /// The thread's control port.
    public var controlPort: Mach.ThreadControl {
        get throws { try getSpecialPort(.control) }
    }

    /// The thread's inspect port.
    public var inspectPort: Mach.ThreadInspect {
        get throws { try getSpecialPort(.inspect) }
    }

    /// The thread's read port.
    public var readPort: Mach.ThreadRead {
        get throws { try getSpecialPort(.read) }
    }
}
