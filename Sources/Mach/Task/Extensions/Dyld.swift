/*
 * Portions Copyright (c) 2016 Apple Inc. All rights reserved.
 *
 * Some comments, particularly those for `State` and `ProcessInfo` are taken from the `dyld` source code. In some cases, minor
 * modifications and fixes have been made to clean up the comments and make them more consistent with the rest of the codebase.
 *
 * @APPLE_LICENSE_HEADER_START@
 *
 * This file contains Original Code and/or Modifications of Original Code
 * as defined in and that are subject to the Apple Public Source License
 * Version 2.0 (the 'License'). You may not use this file except in
 * compliance with the License. Please obtain a copy of the License at
 * http://www.opensource.apple.com/apsl/ and read it before using this
 * file.
 *
 * The Original Code and all software distributed under the License are
 * distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER
 * EXPRESS OR IMPLIED, AND APPLE HEREBY DISCLAIMS ALL SUCH WARRANTIES,
 * INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT.
 * Please see the License for the specific language governing rights and
 * limitations under the License.
 *
 * @APPLE_LICENSE_HEADER_END@
 */

import BSDFS
import Darwin.Mach
import Foundation

extension Mach.Task {
    /// The dyld manager for the task.
    public var dyld: Dyld {
        Dyld(for: self)
    }

    /// A dyld manager for a task.
    /// - Note: Documentation rarely refers to dyld with any capitalization, but Swift convention dictates
    /// that struct names should use PascalCase. Where capitalization is used in documentation to refer to
    /// dyld, it is either PascalCase or ALL_CAPS. However, the latter is only used for constants, so it's
    /// probably safe to assume that PascalCase is the correct capitalization to represent dyld in Swift.
    /// - Warning: This work is covered under license. Please view the source code and <doc:MachTask#Licenses> for more information.
    /// - Warning: Most of the underlying kernel calls are no longer supported. They are kept here for historical purposes.
    public struct Dyld {
        /// The task.
        private let task: Mach.Task

        /// Creates a dyld manager for a given task.
        /// - Parameter task: The task.
        public init(for task: Mach.Task) {
            self.task = task
        }

        /// The dyld notifier ports manager.
        public var notifierPorts: NotifierPorts {
            NotifierPorts(in: self.task)
        }

        /// A dyld notifier ports manager for a task.
        public struct NotifierPorts {
            /// The task.
            public let task: Mach.Task
            /// Creates a dyld notifier ports manager for a given task.
            /// - Parameter task: The task.
            public init(in task: Mach.Task) {
                self.task = task
            }

            /// Registers a port to receive dyld notifications.
            public func register(_ port: Mach.Port) throws {
                try Mach.call(task_dyld_process_info_notify_register(self.task.name, port.name))
            }

            /// Deregisters a port from receiving dyld notifications.
            public func deregister(_ port: Mach.Port) throws {
                try Mach.call(task_dyld_process_info_notify_deregister(self.task.name, port.name))
            }

            /// Gets the ports registered to receive dyld notifications for the current task.
            /// - Important: Unfortunately, there does not appear to be a way to get the ports registered
            /// to receive dyld notifications for an arbitrary task.
            public static func getForCurrentTask() throws -> [Mach.Port] {
                var count = natural_t(8)  // DYLD_MAX_PROCESS_INFO_NOTIFY_COUNT
                let names = mach_port_name_array_t.allocate(
                    capacity: Int(count)
                )
                defer { names.deallocate() }
                try Mach.call(task_dyld_process_info_notify_get(names, &count))
                return (0..<count).map {
                    Mach.Port(named: names.advanced(by: Int($0)).pointee)
                }
            }
        }

        /// A dyld state.
        public enum State: UInt8 {
            /// The state is unknown.
            case unknown = 0xFF

            /// The process is suspended, dyld has not started running yet.
            case notStarted = 0x00

            /// Dyld has initialized itself.
            case initialized = 0x10

            /// The process was terminated due to a missing library or symbol before it got to `main()`.
            case terminatedBeforeInits = 0x20

            /// Dyld has run libSystem's initializer.
            case libSystemInitialized = 0x30

            /// Dyld is running other initializers.
            case runningOtherInitializers = 0x40

            /// Dyld has finished and jumped into `main()``.
            case programIsRunning = 0x50

            /// The process was terminated by dyld post-main (e.g. bad lazying binding info).
            case terminated = 0x60
        }

        /// Information about dyld in a process.
        public struct ProcessInfo: RawRepresentable {
            /// The raw dyld process info.
            public var rawValue: dyld_kernel_process_info_t {
                dyld_kernel_process_info_t(
                    cache_image_info: cacheImageInfo.rawValue,
                    timestamp: lastChangeTimestamp,
                    imageCount: imageCount,
                    initialImageCount: initialImageCount,
                    dyldState: state.rawValue,
                    no_cache: noCache ? 1 : 0,
                    private_cache: privateCache ? 1 : 0
                )
            }

            /// Represents an existing raw dyld process info.
            public init(rawValue: dyld_kernel_process_info_t) {
                self.cacheImageInfo = ImageInfo(rawValue: rawValue.cache_image_info)
                self.lastChangeTimestamp = rawValue.timestamp
                self.imageCount = rawValue.imageCount
                self.initialImageCount = rawValue.initialImageCount
                self.state = State(rawValue: rawValue.dyldState) ?? .unknown
                self.noCache = rawValue.no_cache != 0
                self.privateCache = rawValue.private_cache != 0
            }

            /// The cache image info.
            public let cacheImageInfo: ImageInfo

            /// The timestamp of last time the dyld image list changed.
            public let lastChangeTimestamp: UInt64

            /// The number of images currently loaded into process.
            public let imageCount: UInt32

            /// The number of images statically loaded into process (before any dlopen() calls).
            public let initialImageCount: UInt32

            /// The state.
            public let state: State
            /// Whether the process is running without a dyld cache.
            public let noCache: Bool

            /// Whether the process is using a private copy of its dyld cache
            public let privateCache: Bool
        }

        /// Information about a dyld image.
        public struct ImageInfo: RawRepresentable {
            /// The raw dyld image info.
            public var rawValue: dyld_kernel_image_info {
                dyld_kernel_image_info(
                    uuid: uuid.uuid,
                    fsobjid: objectID.rawValue,
                    fsid: id.rawValue,
                    load_addr: UInt64(UInt(bitPattern: loadAddress))
                )
            }

            /// Represents an existing raw dyld image info.
            public init(rawValue: dyld_kernel_image_info) {
                self.uuid = UUID(uuid: rawValue.uuid)
                self.objectID = BSD.FS.ObjectID(rawValue: rawValue.fsobjid)
                self.id = BSD.FS.ID(rawValue: rawValue.fsid)
                // `load_addr` is a `UInt64`. I wonder what happens on 32-bit systems.
                self.loadAddress = UnsafeRawPointer(bitPattern: UInt(rawValue.load_addr))!
            }

            /// The UUID.
            public let uuid: UUID

            /// The object ID.
            public let objectID: BSD.FS.ObjectID

            /// The ID.
            public let id: BSD.FS.ID

            /// The load address.
            public let loadAddress: UnsafeRawPointer
        }

        /// The dyld process info.
        public var processInfo: ProcessInfo {
            get throws {
                var info = dyld_kernel_process_info_t()
                try Mach.call(task_register_dyld_get_process_state(self.task.name, &info))
                return ProcessInfo(rawValue: info)
            }
        }

        /// Sets the dyld state.
        public func setState(_ state: State) throws {
            try Mach.call(task_register_dyld_set_dyld_state(self.task.name, state.rawValue))
        }

        /// The dyld image infos.
        public var infos: [ImageInfo] {
            get throws {
                var infos: UnsafeMutablePointer<dyld_kernel_image_info>?
                var count = mach_msg_type_number_t.max
                try Mach.call(task_get_dyld_image_infos(self.task.name, &infos, &count))
                return (0..<count).map {
                    ImageInfo(rawValue: infos!.advanced(by: Int($0)).pointee)
                }
            }
        }

        /// Registers dyld image infos.
        public func register(_ infos: [ImageInfo]) throws {
            var rawInfos = infos.map(\.rawValue)
            try Mach.call(
                task_register_dyld_image_infos(
                    self.task.name, &rawInfos, mach_msg_type_number_t(rawInfos.count)
                )
            )
        }

        /// Unregisters dyld image infos.
        public func unregister(_ infos: [ImageInfo]) throws {
            var rawInfos = infos.map(\.rawValue)
            try Mach.call(
                task_unregister_dyld_image_infos(
                    self.task.name, &rawInfos, mach_msg_type_number_t(rawInfos.count)
                )
            )
        }
    }
}
