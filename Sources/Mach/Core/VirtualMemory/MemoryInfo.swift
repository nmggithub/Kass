import Darwin.Mach
import KassC.VMPrivate
import KassHelpers

extension Mach {
    // MARK: - Info Types
    /// A type of memory info.
    public struct MemoryInfoType: KassHelpers.NamedOptionEnum {
        /// Represents a raw info type with an optional name.
        public init(name: String?, rawValue: UInt8) {
            self.name = name
            self.rawValue = rawValue
        }

        /// The name of the info type, if it can be determined.
        public var name: String?

        /// The raw value of the info type.
        public let rawValue: UInt8

        /// All known info types.
        public static let allCases: [Self] = [.tag, .kmod, .kernel, .counter]

        /// The info is about an allocation tag.
        public static let tag = Self(name: "tag", rawValue: UInt8(VM_KERN_SITE_TAG))

        /// The info is about a kernel module.
        public static let kmod = Self(name: "kmod", rawValue: UInt8(VM_KERN_SITE_KMOD))

        /// The info is about the kernel.
        public static let kernel = Self(name: "kernel", rawValue: UInt8(VM_KERN_SITE_KERNEL))

        /// The info is a counter.
        public static let counter = Self(name: "counter", rawValue: UInt8(VM_KERN_SITE_COUNTER))
    }

    // MARK: - Flags
    /// Flags for memory info.
    public struct MemoryInfoFlags: KassHelpers.NamedOptionEnum, OptionSet, Sendable {
        /// Represents a raw flag with an optional name.
        public init(name: String?, rawValue: UInt32) {
            self.name = name
            self.rawValue = rawValue & ~UInt32(VM_KERN_SITE_TYPE)
        }

        /// The name of the flag, if it can be determined.
        public var name: String?

        /// The raw value of the flag.
        public let rawValue: UInt32

        /// The flags that are included in the set.
        public var flags: [Self] {
            Self.allCases.filter { self.contains($0) }
        }

        /// All known flags.
        public static let allCases: [Self] = [.wired, .hide, .named, .zone, .zoneView, .kalloc]

        /// The memory is wired.
        public static let wired = Self(name: "wired", rawValue: UInt32(VM_KERN_SITE_WIRED))

        /// The info is hidden from `zprint`.
        public static let hide = Self(name: "hide", rawValue: UInt32(VM_KERN_SITE_HIDE))

        /// The info is named.
        public static let named = Self(name: "named", rawValue: UInt32(VM_KERN_SITE_NAMED))

        /// The info is about a zone.
        public static let zone = Self(name: "zone", rawValue: UInt32(VM_KERN_SITE_ZONE))

        /// The info is a zone view (statistics).
        public static let zoneView = Self(
            name: "zoneView", rawValue: UInt32(VM_KERN_SITE_ZONE_VIEW)
        )

        /// The info is about a size class for `kalloc`.
        public static let kalloc = Self(name: "kalloc", rawValue: UInt32(VM_KERN_SITE_KALLOC))
    }

    // MARK: - Counters
    /// A type of memory counter.
    public struct MemoryInfoCounterType: KassHelpers.NamedOptionEnum {
        /// Represents a raw counter type with an optional name.
        public init(name: String?, rawValue: UInt64) {
            self.name = name
            self.rawValue = rawValue
        }

        /// The name of the counter type, if it can be determined.
        public var name: String?

        /// The raw value of the counter type.
        public let rawValue: UInt64

        /// All known counter types.
        public static let allCases: [Self] = [
            managed, reserved, wired, wiredManaged, stolen, loPage, mapZone, mapKernel,
            mapKalloc, wiredBoot, bootStolen, wiredStaticKernelcache, mapKallocLargeData,
            mapKernelData,
        ]

        public static let managed = Self(name: "managed", rawValue: UInt64(VM_KERN_COUNT_MANAGED))

        public static let reserved = Self(
            name: "reserved", rawValue: UInt64(VM_KERN_COUNT_RESERVED)
        )

        public static let wired = Self(name: "wired", rawValue: UInt64(VM_KERN_COUNT_WIRED))

        public static let wiredManaged = Self(
            name: "wiredManaged", rawValue: UInt64(VM_KERN_COUNT_WIRED_MANAGED)
        )

        public static let stolen = Self(name: "stolen", rawValue: UInt64(VM_KERN_COUNT_STOLEN))

        public static let loPage = Self(name: "loPage", rawValue: UInt64(VM_KERN_COUNT_LOPAGE))

        public static let mapZone = Self(name: "mapZone", rawValue: UInt64(VM_KERN_COUNT_MAP_ZONE))

        public static let mapKernel = Self(
            name: "mapKernel", rawValue: UInt64(VM_KERN_COUNT_MAP_KERNEL)
        )

        public static let mapKalloc = Self(
            name: "mapKalloc", rawValue: UInt64(VM_KERN_COUNT_MAP_KALLOC)
        )

        public static let wiredBoot = Self(
            name: "wiredBoot", rawValue: UInt64(VM_KERN_COUNT_WIRED_BOOT)
        )

        public static let bootStolen = Self(
            name: "bootStolen", rawValue: UInt64(VM_KERN_COUNT_BOOT_STOLEN)
        )

        public static let wiredStaticKernelcache = Self(
            name: "wiredStaticKernelcache",
            rawValue: UInt64(VM_KERN_COUNT_WIRED_STATIC_KERNELCACHE)
        )

        public static let mapKallocLargeData = Self(
            name: "mapKallocLargeData",
            rawValue: UInt64(VM_KERN_COUNT_MAP_KALLOC_LARGE_DATA)
        )

        public static let mapKernelData = Self(
            name: "mapKernelData", rawValue: UInt64(VM_KERN_COUNT_MAP_KERNEL_DATA)
        )
    }
}

// MARK: - mach_memory_info
/// Information about memory.
extension mach_memory_info {
    /// The name of the info, if it can be determined.
    public var nameString: String? {
        let maybeName = withUnsafePointer(to: self.name) {
            pointer in
            pointer.withMemoryRebound(
                to: CChar.self,
                capacity: Int(MACH_MEMORY_INFO_NAME_MAX_LEN)
            ) { String(cString: $0) }
        }
        return maybeName != "" ? maybeName : nil
    }

    /// The type of the memory info.
    public var infoType: Mach.MemoryInfoType {
        Mach.MemoryInfoType(rawValue: UInt8(self.flags & UInt64(VM_KERN_SITE_TYPE)))
    }

    /// The tag of the info, if it is a tag.
    public var tagValue: Mach.VMTag? {
        guard self.infoType == .tag else { return nil }
        return Mach.VMTag(rawValue: Int32(self.tag))
    }

    /// The type of counter, if the info is a counter.
    public var counterType: Mach.MemoryInfoCounterType? {
        guard self.infoType == .counter else { return nil }
        return Mach.MemoryInfoCounterType(rawValue: self.site)
    }

    /// The ID of the kernel module, if it is a kernel module.
    public var kernelModuleID: UInt32? {
        guard self.infoType == .kmod else { return nil }
        return UInt32(self.site)
    }

    /// The flags of the info.
    public var flagSet: Mach.MemoryInfoFlags {
        Mach.MemoryInfoFlags(rawValue: UInt32(self.flags))
    }
}

// MARK: - Memory Infos
extension Mach.Host {
    /// The memory infos in the host.
    public var memoryInfos: [mach_memory_info] {
        get throws {
            // These are ignored by us, but required by the kernel call.
            var names: mach_zone_name_array_t?
            var nameCount = mach_msg_type_number_t.max
            var infos: mach_zone_info_array_t?
            var infoCount = mach_msg_type_number_t.max

            var memoryInfos: mach_memory_info_array_t?
            var memoryInfoCount = mach_msg_type_number_t.max
            try Mach.call(
                mach_memory_info(
                    self.name, &names, &nameCount, &infos, &infoCount,
                    &memoryInfos, &memoryInfoCount
                )
            )
            return (0..<Int(memoryInfoCount)).map { memoryInfos![$0] }
        }
    }
}
