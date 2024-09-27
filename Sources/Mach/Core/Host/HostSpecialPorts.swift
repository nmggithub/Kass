/*
 * Portions Copyright (c) 2003 Apple Computer, Inc. All rights reserved.
 *
 * The list of special ports (particularly those after the max) is taken from the XNU source code.
 *
 * Other code besides the Swift enum is unique to this file and is not sourced from the original file.
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
 * Copyright (c) 1991 Carnegie Mellon University
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
 *	File:	mach/host_special_ports.h
 *
 *	Defines codes for access to host-wide special ports.
 */

import Darwin.Mach

extension Mach {
    /// A special port for a host.
    /// - Warning: This work is covered under license. Please view the source code and <doc:MachCore#Licenses> for more information.
    public enum HostSpecialPort: Int32, Mach.Port.SpecialPortType {
        /// The parent port type.
        typealias ParentPort = Mach.Host

        /// Gets a special port for the host.
        public func get<PortType: Mach.Port>(
            for host: Mach.Host = .current, as type: PortType.Type = PortType.self
        ) throws -> PortType {
            try host.getSpecialPort(self, as: type)
        }

        /// Sets a special port for the host.
        public func set(for host: Mach.Host = .current, to port: Mach.Port) throws {
            try host.setSpecialPort(self, to: port)
        }

        /// A unprivileged host port.
        case host = 1

        /// A privileged host port.
        case hostPriv = 2

        /// A main device port.
        case ioMain = 3

        @available(*, unavailable)
        case max = 7
        // based on increments from the max

        case dynamicPager  // unknown

        case auditControl  // unknown

        case userNotification  // `launchd`

        /// A port to `automountd`.
        case automountd

        case lockd  // `launchd`

        case ktraceBackground  // `launchd`

        /// A port to `sandboxd`.
        case seatbelt

        /// A port to `kextd` (now `kernelmanagerd`).
        case kextd

        case launchctl  // unknown

        /// Another port to `fairplayd`.
        case unfreed  // `fairplayd`

        /// A port to `amfid`.
        case amfid

        case gssd  // `launchd`

        /// A port to `UserEventAgent`.
        case telemetry

        case atmNotification  // unknown

        case coalition  // `launchd`

        /// A port to `sysdiagnosed`.
        case sysdiagnosed

        case xpcException  // unknown

        case containerd  // unknown

        case node  // unknown

        /// A port to `symptomsd`.
        case resourceNotify

        case closured  // unknown

        /// A port to `syspolicyd`.
        case syspolicyd

        /// A port to `filecoordinationd`
        case filecoordinationd

        /// A port to `fairplayd`.
        case fairplayd

        case ioCompressionStats  // unknown

        /// A port to `mmaintenanced`.
        case memoryError

        /// (Probably) a port to `managedappdistributiond`.
        case managedappdistd  // unknown
    }
}

extension Mach.Host: Mach.Port.WithSpecialPorts {
    /// Gets a special port for the host.
    public func getSpecialPort<PortType: Mach.Port>(
        _ specialPort: Mach.HostSpecialPort, as type: PortType.Type = PortType.self
    ) throws -> PortType {
        var portName = mach_port_name_t()
        try Mach.call(
            // for historical reasons, we pass in HOST_LOCAL_NODE as the second parameter
            host_get_special_port(self.name, HOST_LOCAL_NODE, specialPort.rawValue, &portName)
        )
        return PortType(named: portName)
    }

    /// Sets a special port for the host.
    public func setSpecialPort(_ specialPort: Mach.HostSpecialPort, to port: Mach.Port) throws {
        try Mach.call(
            host_set_special_port(self.name, specialPort.rawValue, port.name)
        )
    }
}

extension Mach.Host {
    /// The unprivileged host port.
    public var hostPort: Mach.Host {
        get throws { try getSpecialPort(.host) }
    }

    /// The privileged host port.
    /// - Important: On unprivileged tasks, this will return the same as ``hostPort``.
    public var hostPortPrivileged: Mach.Host {
        get throws { try getSpecialPort(.hostPriv) }
    }
}
