/*
 * Copyright (c) 2000-2010 Apple Computer, Inc. All rights reserved.
 *
* The list of special ports is taken from the XNU source code.
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
 *	File:	mach/task_special_ports.h
 *
 *	Defines codes for special_purpose task ports.  These are NOT
 *	port identifiers - they are only used for the task_get_special_port
 *	and task_set_special_port routines.
 *
 */

import Darwin.Mach

extension Mach {
    /// A special port for a task.
    /// - Warning: This work is covered under license. Please view the source code and <doc:MachCore#Licenses> for more information.
    public enum TaskSpecialPort: task_special_port_t, Mach.Port.SpecialPortType {
        /// The parent port type.
        internal typealias ParentPort = Mach.Task

        /// Gets the special port for a task.
        public func get<PortType: Mach.Port>(
            for task: Mach.Task = .current, as type: PortType.Type = PortType.self
        ) throws -> PortType {
            try task.getSpecialPort(self, as: type)
        }

        /// Sets the special port for a task.
        public func set(for task: Mach.Task = .current, to port: Mach.Port) throws {
            try task.setSpecialPort(self, to: port)
        }

        /// The task's control port.
        case control = 1

        /// The host port for the host that the task is in.
        case host = 2

        /// The task's name port.
        case name = 3

        /// The bootstrap port, used to get ports for Mach services.
        case bootstrap = 4

        /// The task's inspect port.
        case inspect = 5

        /// The task's read port.
        case read = 6

        @available(macOS, obsoleted: 12.0.1)
        case seatbelt = 7

        @available(macOS, obsoleted: 10.8)
        /// - Note: If you can even get Swift code to compile for Max OS X Lion or earlier, more power to you.
        case gssd = 8

        /// A port for determining access to the different flavored task ports for the task.
        case access = 9

        /// The task's debug port.
        case debug = 10
    }

}

extension Mach.Task: Mach.Port.WithSpecialPorts {
    /// Gets a special port for the task.
    public func getSpecialPort<PortType: Mach.Port>(
        _ specialPort: Mach.TaskSpecialPort, as type: PortType.Type = PortType.self
    ) throws -> PortType {
        var portName = mach_port_name_t()
        try Mach.call(
            task_get_special_port(self.name, specialPort.rawValue, &portName)
        )
        return PortType(named: portName)
    }

    /// Sets a special port for the task.
    public func setSpecialPort(_ specialPort: Mach.TaskSpecialPort, to port: Mach.Port) throws {
        try Mach.call(
            task_set_special_port(self.name, specialPort.rawValue, port.name)
        )
    }
}

extension Mach.Task {
    /// The port for the host that the task is in.
    public var hostPort: Mach.Host {
        get throws { try getSpecialPort(.host) }
    }

    /// The task's control port.
    public var controlPort: Mach.TaskControl {
        get throws { try getSpecialPort(.control) }
    }

    /// The task name port.
    public var namePort: Mach.TaskName {
        get throws { try getSpecialPort(.name) }
    }

    /// The task's inspect port.
    public var inspectPort: Mach.TaskInspect {
        get throws { try getSpecialPort(.inspect) }
    }

    /// The task's read port.
    public var readPort: Mach.TaskRead {
        get throws { try getSpecialPort(.read) }
    }

    /// The access port for the task.
    public var accessPort: Mach.Port {
        get throws { try getSpecialPort(.access) }
    }

    /// The task's debug port.
    public var debugPort: Mach.Port {
        get throws { try getSpecialPort(.debug) }
    }
}
