import Darwin.Mach
import Foundation
import KassC.OSKextLibPrivate
import KassHelpers

/// Adds a failible initializer to convert a potentially-nil data pointer to a Swift `Data` object.
// TODO: Determine if duplicating this from TaskDyldInfo.swift is an appropriate breaking of DRY.
extension Data {
    fileprivate init?(bytes: UnsafeRawPointer?, count: Int) {
        guard let actualBytes = bytes else { return nil }
        self.init(bytes: actualBytes, count: count)
    }
}

extension Mach {
    /// A host.
    public class Host: Mach.Port {
        /// The current host.
        public static var current: Self { Self(named: mach_host_self()) }

        /// Wether the host port is privileged.
        /// - Important: This property accessor is throwing as it calls
        /// the kernel to determine the underlying kernel object type.
        /// - Warning: This property accessor will crash the program if
        /// it determines that the port isn't actually a host port.
        public var isPrivileged: Bool {
            get throws {
                switch try self.kernelObject.type {
                case .hostPriv: true
                case .host: false
                default: fatalError("Not actually a host port!")
                }
            }
        }

        /// The boot info for the host.
        public var bootInfo: String {
            get throws {
                let bootInfoStr = UnsafeMutablePointer<CChar>.allocate(
                    capacity: Int(KERNEL_BOOT_INFO_MAX)
                )
                try Mach.call(host_get_boot_info(self.name, bootInfoStr))
                return String(cString: bootInfoStr)
            }
        }

        /// The kernel version for the host.
        public var kernelVersion: String {
            get throws {
                let kernelVersionStr = UnsafeMutablePointer<CChar>.allocate(
                    capacity: Int(512)
                )
                try Mach.call(host_kernel_version(self.name, kernelVersionStr))
                return String(cString: kernelVersionStr)
            }
        }

        /// The page size for the host.
        public var pageSize: vm_size_t {
            get throws {
                var pageSize: vm_size_t = 0
                try Mach.call(host_page_size(self.name, &pageSize))
                return pageSize
            }
        }
    }
}

extension Mach {
    /// A reboot option.
    public struct HostRebootOption:
        // The way the `host_reboot` function is defined, it seems it could take more than one option. However,
        // it functionally only ever *uses* one option. So, we'll just define it as a single-option enum.
        KassHelpers.OptionEnum
    {
        public let rawValue: Int32
        public init(rawValue: Int32) { self.rawValue = rawValue }

        /// Don't reboot, just halt.
        public static let halt = Self(rawValue: HOST_REBOOT_HALT)

        /// Reboot after a delay.
        /// - Note: This technically tells the kernel there was a UPS power failure.
        public static let upsDelay = Self(rawValue: HOST_REBOOT_UPSDELAY)

        /// Don't actually reboot, just drop into debugger.
        /// - Note: This is only available on debug kernel builds.
        public static let debugger = Self(rawValue: HOST_REBOOT_DEBUGGER)
    }
}
extension Mach.Host {
    /// Reboots the host.
    public func reboot(option: Mach.HostRebootOption = .init(rawValue: 0)) throws {
        try Mach.call(host_reboot(self.name, option.rawValue))
    }
}

extension Mach.Host {
    /// Performs a kext request and returns more information.
    /// - Important: This function will not throw if the request fails. Instead, it will
    // return the error code and any log data that was generated through the process.
    /// - Important: See the source code for more information on the `logSpec` parameter.
    public func kextRequestWithLogging(_ request: Data, logSpec: OSKextLogSpec = 0) throws -> (
        return: kern_return_t, logData: Data?, response: Data?
    ) {
        let dataCopy = request.withUnsafeBytes {
            buffer in
            let bufferCopy = UnsafeMutableRawBufferPointer.allocate(
                byteCount: buffer.count, alignment: 1
            )
            bufferCopy.copyMemory(from: buffer)
            return bufferCopy
        }
        defer { dataCopy.deallocate() }
        var responseAddress = vm_offset_t()
        var responseCount = mach_msg_type_number_t()
        var actualReturn = kern_return_t()
        var logDataPointer = vm_offset_t()
        var logDataCount = mach_msg_type_number_t()
        try Mach.call(
            kext_request(
                self.name,
                logSpec,
                vm_offset_t(bitPattern: dataCopy.baseAddress),
                mach_msg_type_number_t(request.count),
                &responseAddress, &responseCount,
                &logDataPointer, &logDataCount, &actualReturn
            )
        )
        let response = Data(
            bytes: UnsafeRawPointer(bitPattern: responseAddress),
            count: Int(responseCount)
        )
        let logData = Data(
            bytes: UnsafeRawPointer(bitPattern: logDataPointer),
            count: Int(logDataCount)
        )
        return (actualReturn, logData, response)
    }

    /// Performs a kext request.
    public func kextRequest(_ request: Data) throws -> Data {
        let (returnCode, _, data) = try self.kextRequestWithLogging(request)
        try Mach.call(returnCode)
        return data!  // Hopefully the above line will throw in cases where `data` is nil.
    }
}

extension Mach {
    /// A memory manager.
    public class MemoryManager: Mach.Port {}
}

extension Mach.Host {
    /// Gets the default memory manager for the host.
    public func getDefaultMemoryManager() throws -> Mach.MemoryManager {
        var name = mach_port_name_t()
        try Mach.call(
            host_default_memory_manager(self.name, &name, 0)
        )
        return Mach.MemoryManager(named: name)
    }

    /// Sets the default memory manager for the host.
    /// - Warning: Only the kernel task can set the default memory manager.
    public func setDefaultMemoryManager(to manager: Mach.MemoryManager) throws {
        var name = manager.name
        try Mach.call(
            host_default_memory_manager(self.name, &name, 0)
        )
    }
}
