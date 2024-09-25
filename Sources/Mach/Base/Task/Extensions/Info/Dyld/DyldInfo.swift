/*
 * Portions Copyright (c) 2006-2010 Apple Inc. All rights reserved.
 * Original file: /include/mach-o/dyld_images.h
 *
 * Most of the structures here are taken from the `dyld` source code.
 *
 * Portions Copyright (c) 2017 Apple Inc. All rights reserved.
 * Original file: /cache-builder/mrm_shared_cache_builder.h
 *
 * The `DyldPlatform` enumeration is also taken from the `dyld` source code.
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

import Darwin.Mach
import Foundation
import MachO.dyld

extension Mach.Task {
    /// An operation that `dyld` is performing on a set of images.
    /// - Warning: This work is covered under license. Please view the source code and <doc:MachTask#Licenses> for more information.
    public enum DyldImageMode: Int32 {
        case adding = 0
        case removing = 1
        case change = 2
        case move = 3
    }

    /// Information a `dyld` image.
    /// - Warning: This work is covered under license. Please view the source code and <doc:MachTask#Licenses> for more information.
    public struct DyldImageInfo: Hashable {
        public let imageLoadAddress: UnsafePointer<mach_header>?
        internal let imageFilePathCString: UnsafePointer<CChar>?
        public var imageFilePath: String? {
            guard let imageFilePath = self.imageFilePathCString else { return nil }
            return String(cString: imageFilePath)
        }
        internal let imageFileModDate: UnsafeRawPointer
    }

    /// A `dyld` image's load address and UUID.
    /// - Warning: This work is covered under license. Please view the source code and <doc:MachTask#Licenses> for more information.
    public struct DyldUUIDInfo {
        public let imageLoadAddress: UnsafePointer<mach_header>?
        public let imageUUID: uuid_t
    }

    /// Information about an ahead-of-time (AoT) compiled image.
    /// - Warning: This work is covered under license. Please view the source code and <doc:MachTask#Licenses> for more information.
    public struct AotImageInfo {
        public let x86LoadAddress: UnsafePointer<mach_header>?
        public let aotLoadAddress: UnsafePointer<mach_header>?
        public let aotImageSize: UInt64
        internal let aotImageKeyBytes:
            (
                UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
                UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
                UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
                UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8
            )
        public var aotImageKey: Data {
            withUnsafeBytes(of: self.aotImageKeyBytes) { Data($0) }
        }
    }

    /// A function that is called when `dyld` images are loaded or unloaded.
    /// - Warning: This work is covered under license. Please view the source code and <doc:MachTask#Licenses> for more information.
    internal typealias DyldImageNotifier = @convention(c) (
        _ mode: DyldImageMode.RawValue, _ infoCount: Int32, _ infos: UnsafeRawPointer
    ) -> Void

    /// An error kind for `dyld``.
    /// - Warning: This work is covered under license. Please view the source code and <doc:MachTask#Licenses> for more information.
    public enum DyldErrorKind: Int32 {
        case none = 0
        case dylibMissing = 1
        case dylibWrongArchitecture = 2
        case symbolMissing = 3
    }

    /// An error that `dyld` encountered.
    /// - Warning: This work is covered under license. Please view the source code and <doc:MachTask#Licenses> for more information.
    /// - Note: While this structure doesn't map directly to any `dyld` structure, its contents do map
    /// directly to `dyld`'s error information, so it's marked as covered under the same license.
    public struct DyldError {
        public let message: String?
        public let kind: DyldErrorKind?
        public let clientOfDylibPath: String?
        public let targetDylibPath: String?
        public let symbol: String?
    }

    /// A platform identifier for `dyld`.
    /// - Warning: This work is covered under license. Please view the source code and <doc:MachTask#Licenses> for more information.
    public enum DyldPlatform: Int32 {
        case unknown = 0
        case macOS = 1
        case iOS = 2
        case tvOS = 3
        case watchOS = 4
        case bridgeOS = 5
        case iOSMac = 6
        case iOS_simulator = 7
        case tvOS_simulator = 8
        case watchOS_simulator = 9
        case driverKit = 10
        case macOSExclaveKit = 16
        case iOSExclaveKit = 18
    }

    /// Information about `dyld` images in the task.
    /// - Warning: This work is covered under license. Please view the source code and <doc:MachTask#Licenses> for more information.
    public struct DyldAllImageInfos: BitwiseCopyable {
        public let version: UInt32
        internal let infoArrayCount: UInt32
        internal let infoArray: UnsafePointer<DyldImageInfo>?
        public var infos: [DyldImageInfo] {
            guard let infoArray = self.infoArray else { return [] }
            return (0..<Int(self.infoArrayCount)).map {
                infoArray.advanced(by: $0).pointee
            }
        }
        internal let notification: DyldImageNotifier?
        public func notify(mode: DyldImageMode, infos: consuming Set<DyldImageInfo>) {
            self.notification?(mode.rawValue, Int32(infos.count), Array(infos))
        }
        internal let processDetachedFromSharedRegionCXXBool: UInt8
        public var processDetachedFromSharedRegion: Bool {
            self.processDetachedFromSharedRegionCXXBool != 0
        }

        // Introduced in version 2 (Mac OS X 10.6+)
        @available(macOS, introduced: 10.6)
        internal let libSystemInitializedCXXBool: UInt8
        @available(macOS, introduced: 10.6)
        public var libSystemInitialized: Bool {
            self.libSystemInitializedCXXBool != 0
        }
        #if arch(arm64) || arch(x86_64)
            @available(macOS, introduced: 10.6)
            private let padding: (UInt8, UInt8, UInt8, UInt8)
        #elseif arch(arm) || arch(i386)
            @available(macOS, introduced: 10.6)
            private let padding: (UInt8, UInt8)
        #else
            #error("Unsupported architecture")
        #endif
        @available(macOS, introduced: 10.6)
        public let dyldImageLoadAddress: UnsafePointer<mach_header>?

        // Introduced in version 3 (also Mac OS X 10.6+)
        @available(macOS, introduced: 10.6)
        public let jitInfo: UnsafeRawPointer?

        // Introduced in version 5 (also Mac OS X 10.6+)
        @available(macOS, introduced: 10.6)
        internal let dyldVersionCString: UnsafePointer<CChar>?
        @available(macOS, introduced: 10.6)
        public var dyldVersion: String? {
            guard let dyldVersionCString = self.dyldVersionCString else { return nil }
            return String(cString: dyldVersionCString)
        }
        @available(macOS, introduced: 10.6)
        internal let errorMessageCString: UnsafePointer<CChar>?
        @available(macOS, introduced: 10.6)
        public var errorMessage: String? {
            guard let errorMessageCString = self.errorMessageCString else { return nil }
            return String(cString: errorMessageCString)
        }
        @available(macOS, introduced: 10.6)
        public let terminationFlags: UInt

        // Introduced in version 6 (also Mac OS X 10.6+)
        @available(macOS, introduced: 10.6)
        public let coreSymbolicationSharedMemoryPage: UnsafeRawPointer?

        // Introduced in version 7 (also Mac OS X 10.6+)
        @available(macOS, introduced: 10.6)
        public let systemOrderFlag: UnsafeRawPointer?

        // Introduced in version 8 (also Mac OS X 10.6+)
        @available(macOS, introduced: 10.6)
        internal let uuidArrayCount: UInt
        @available(macOS, introduced: 10.6)
        internal let uuidArray: UnsafeRawPointer?
        @available(macOS, introduced: 10.6)
        public var uuids: [DyldUUIDInfo] {
            guard let uuidArray = self.uuidArray else { return [] }
            return (0..<Int(self.uuidArrayCount)).map {
                uuidArray.load(
                    fromByteOffset: $0 * MemoryLayout<DyldUUIDInfo>.stride, as: DyldUUIDInfo.self)
            }
        }

        // Introduced in version 9 (Mac OS X 10.7+)
        @available(macOS, introduced: 10.7)
        public let dyldAllImageInfosAddress: UnsafePointer<DyldAllImageInfos>?  // why are we pointing to a struct of the same type (ourselves?)?

        // Introduced in version 10 (also Mac OS X 10.7+)
        @available(macOS, introduced: 10.7)
        public let initialImageCount: UInt

        // Introduced in version 11 (also Mac OS X 10.7+)
        @available(macOS, introduced: 10.7)
        internal let errorKindCode: UInt
        @available(macOS, introduced: 10.7)
        public var errorKind: DyldErrorKind? {
            DyldErrorKind(rawValue: Int32(self.errorKindCode))
        }
        @available(macOS, introduced: 10.7)
        internal let errorClientOfDylibPathCString: UnsafePointer<CChar>?
        @available(macOS, introduced: 10.7)
        public var errorClientOfDylibPath: String? {
            guard let errorClientOfDylibPathCString = self.errorClientOfDylibPathCString else {
                return nil
            }
            return String(cString: errorClientOfDylibPathCString)
        }
        @available(macOS, introduced: 10.7)
        internal let errorTargetDylibPathCString: UnsafePointer<CChar>?
        @available(macOS, introduced: 10.7)
        public var errorTargetDylibPath: String? {
            guard let errorTargetDylibPathCString = self.errorTargetDylibPathCString else {
                return nil
            }
            return String(cString: errorTargetDylibPathCString)
        }
        @available(macOS, introduced: 10.7)
        internal let errorSymbolCString: UnsafePointer<CChar>?
        @available(macOS, introduced: 10.7)
        public var errorSymbol: String? {
            guard let errorSymbolCString = self.errorSymbolCString else { return nil }
            return String(cString: errorSymbolCString)
        }
        @available(macOS, introduced: 10.7)
        public var error: DyldError {
            DyldError(
                message: self.errorMessage,
                kind: self.errorKind,
                clientOfDylibPath: self.errorClientOfDylibPath,
                targetDylibPath: self.errorTargetDylibPath,
                symbol: self.errorSymbol
            )
        }

        // Introduced in version 12 (also Mac OS X 10.7+)
        @available(macOS, introduced: 10.7)
        public let sharedCacheSlide: UnsafeRawPointer?

        // Introduced in version 13 (Mac OS X 10.9+)
        @available(macOS, introduced: 10.9)
        public let sharedCacheUUID: uuid_t

        // Introduced in version 15 (macOS 10.12+)
        @available(macOS, introduced: 10.12)
        public let sharedCacheBaseAddress: UnsafeRawPointer?
        @available(macOS, introduced: 10.12)
        public let infoArrayChangeTimestamp: UInt64
        @available(macOS, introduced: 10.12)
        internal let dyldPathCString: UnsafePointer<CChar>?
        @available(macOS, introduced: 10.12)
        public var dyldPath: String? {
            guard let dyldPathCString = self.dyldPathCString else { return nil }
            return String(cString: dyldPathCString)
        }
        @available(macOS, introduced: 10.12)
        public let notifyPorts:
            // These are just port names with no indication of what name space they're in,
            // so we'll just use `mach_port_name_t` instead of our own `Mach.Port` class.
            (
                mach_port_name_t, mach_port_name_t, mach_port_name_t, mach_port_name_t,
                mach_port_name_t, mach_port_name_t, mach_port_name_t, mach_port_name_t
            )

        #if arch(arm64) || arch(x86_64)
            @available(macOS, introduced: 10.12)
            public let reserved:
                (
                    UnsafeRawPointer?, UnsafeRawPointer?, UnsafeRawPointer?, UnsafeRawPointer?,
                    UnsafeRawPointer?, UnsafeRawPointer?, UnsafeRawPointer?, UnsafeRawPointer?,
                    UnsafeRawPointer?
                )
        #elseif arch(arm) || arch(i386)
            @available(macOS, introduced: 10.12)
            public let reserved:
                (
                    UnsafeRawPointer?, UnsafeRawPointer?, UnsafeRawPointer?, UnsafeRawPointer?,
                    UnsafeRawPointer?
                )
        #else
            #error("Unsupported architecture")
        #endif

        // Introduced in version 16 (macOS 10.13+)
        @available(macOS, introduced: 10.13)
        internal let compact_dyld_image_info_addr: UnsafeRawPointer?
        @available(macOS, introduced: 10.13)
        internal let compact_dyld_image_info_size: UInt
        @available(macOS, introduced: 10.13)
        public var compactDyldImageInfo: Data? {
            guard let addr = self.compact_dyld_image_info_addr else { return nil }
            return Data(
                bytes: addr,
                count: Int(self.compact_dyld_image_info_size)
            )
        }

        @available(macOS, introduced: 10.13)
        internal let platformId: UInt32
        @available(macOS, introduced: 10.13)
        public var platform: DyldPlatform {
            DyldPlatform(rawValue: Int32(self.platformId)) ?? .unknown
        }

        // Introduced in version 17 (macOS 10.16+)
        #if arch(arm64) || arch(x86_64)
            @available(macOS, introduced: 10.16)
            internal let aotInfoArrayCount: UInt32
            @available(macOS, introduced: 10.16)
            internal let aotInfoArray: UnsafePointer<AotImageInfo>?
            @available(macOS, introduced: 10.16)
            public var aotInfos: [AotImageInfo] {
                guard let aotInfoArray = self.aotInfoArray else { return [] }
                return (0..<Int(self.aotInfoArrayCount)).map {
                    aotInfoArray.advanced(by: $0).pointee
                }
            }
            @available(macOS, introduced: 10.16)
            public let aotInfoArrayChangeTimestamp: UInt64
            @available(macOS, introduced: 10.16)
            public let aotSharedCacheBaseAddress: UnsafeRawPointer?
            @available(macOS, introduced: 10.16)
            public let aotSharedCacheUUID: uuid_t
        #endif
    }

    /// Information about `dyld` images in the task.
    public var dyldInfo: DyldAllImageInfos {
        get throws {
            let dyldInfo: task_dyld_info = try self.getInfo(.dyld)
            guard let infoPointer = UnsafeRawPointer(bitPattern: UInt(dyldInfo.all_image_info_addr))
            else { fatalError("`task_info` returned a null pointer for the `dyld` info.") }
            guard MemoryLayout<DyldAllImageInfos>.size >= dyldInfo.all_image_info_size
            else {
                fatalError("The size of the `dyld` info struct doesn't match the expected size.")
            }
            return infoPointer.load(as: DyldAllImageInfos.self)
        }
    }
}
