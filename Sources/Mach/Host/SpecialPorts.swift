/*
 * Portions Copyright (c) 2003 Apple Computer, Inc. All rights reserved.
 *
 * The main difference between this file and the original file is that the original file is written in C, while this file is written in Swift.
 *
 * Specifically, the original file is a collection of C preprocessor macros, while this file is a Swift enum.
 * The original macros are written in ALL_CAPS_SNAKE_CASE, while the Swift enum cases are written in camelCase.
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

extension Mach.Host {
    /// A special port for a host.
    /// - Warning: This work is covered under license. Please view the source code and <doc:MachHost#Licenses> for more information.
    public enum SpecialPort: Int32 {
        case security = 0
        case host = 1
        case priv = 2
        case ioMain = 3
        @available(*, unavailable)
        case max = 7
        // based on increments from the max
        case dynamicPager
        case auditControl
        case userNotification
        case automountd
        case lockd
        case ktraceBackground
        case seatbelt
        case kextd
        case launchctl
        case unfreed
        case amfid
        case gssd
        case telemetry
        case atmNotification
        case coaltion
        case sysdiagnose
        case xpcException
        case containerd
        case node
        case resourceNotify
        case closured
        case syspolicyd
        case filecoordinationd
        case fairplayd
        case ioCompressionStats
        case memoryError
        case managedappdistd
    }

    /// Gets a special port for the host.
    /// - Parameters:
    ///   - specialPort: The special port to get.
    ///   - type: The type to reference the port as.
    /// - Throws: An error if the port cannot be retrieved.
    /// - Returns: The special port.
    public func getSpecialPort<PortType: Mach.Port>(
        _ specialPort: SpecialPort, as type: PortType.Type = Mach.Port.self
    ) throws -> PortType {
        var portName = mach_port_name_t()
        try Mach.call(
            // for historical reasons, we pass in HOST_LOCAL_NODE as the second parameter
            host_get_special_port(self.name, HOST_LOCAL_NODE, specialPort.rawValue, &portName)
        )
        return PortType(named: portName)
    }

    /// Sets a special port for the host.
    /// - Parameters:
    ///   - specialPort: The special port to set.
    ///   - port: The port to set as the special port.
    /// - Throws: An error if the port cannot be set.
    public func setSpecialPort(_ specialPort: SpecialPort, to port: Mach.Port) throws {
        try Mach.call(
            host_set_special_port(self.name, specialPort.rawValue, port.name)
        )
    }
}
