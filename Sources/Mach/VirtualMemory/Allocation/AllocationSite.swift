import Darwin.Mach
import MachC.VMStatistics

extension Mach {
    // MARK: - Info Types
    /// A type of memory info.
    public struct MemoryInfoType: Mach.OptionEnum, Mach.NamedOptionEnum {
        /// Represents a info type with an optional name and a raw value.
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
    public struct MemoryInfoFlags: Mach.NamedOptionEnum, OptionSet, Sendable {
        /// Represents a flag with an optional name and a raw value.
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

    // MARK: - Tags
    /// A tag for memory info.
    public struct MemoryInfoTag: Mach.OptionEnum, Mach.NamedOptionEnum {
        /// Represents a tag with an optional name and a raw value.
        public init(name: String?, rawValue: UInt16) {
            self.name = name
            self.rawValue = rawValue
        }

        /// The name of the tag, if it can be determined.
        public var name: String?

        /// The raw value of the tag.
        public let rawValue: UInt16

        /// All known tags.
        public static let allCases: [Self] = [
            none, osfmk, bsd, iokit, libkern, oskext, kext, ipc, stack, cpu, pmap, pte, zone,
            kalloc, compressor, compressedData, phantomCache, waitq, diag, log, file, mbuf, ubc,
            security, mlock, reason, skywalk, ltable, hv, kallocData, retired, kallocType, triage,
            recount, exclaves,
        ]

        public static let none = Self(name: "none", rawValue: UInt16(VM_KERN_MEMORY_NONE))

        public static let osfmk = Self(name: "osfmk", rawValue: UInt16(VM_KERN_MEMORY_OSFMK))

        public static let bsd = Self(name: "bsd", rawValue: UInt16(VM_KERN_MEMORY_BSD))

        public static let iokit = Self(name: "iokit", rawValue: UInt16(VM_KERN_MEMORY_IOKIT))

        public static let libkern = Self(name: "libkern", rawValue: UInt16(VM_KERN_MEMORY_LIBKERN))

        public static let oskext = Self(name: "oskext", rawValue: UInt16(VM_KERN_MEMORY_OSKEXT))

        public static let kext = Self(name: "kext", rawValue: UInt16(VM_KERN_MEMORY_KEXT))

        public static let ipc = Self(name: "ipc", rawValue: UInt16(VM_KERN_MEMORY_IPC))

        public static let stack = Self(name: "stack", rawValue: UInt16(VM_KERN_MEMORY_STACK))

        public static let cpu = Self(name: "cpu", rawValue: UInt16(VM_KERN_MEMORY_CPU))

        public static let pmap = Self(name: "pmap", rawValue: UInt16(VM_KERN_MEMORY_PMAP))

        public static let pte = Self(name: "pte", rawValue: UInt16(VM_KERN_MEMORY_PTE))

        public static let zone = Self(name: "zone", rawValue: UInt16(VM_KERN_MEMORY_ZONE))

        public static let kalloc = Self(name: "kalloc", rawValue: UInt16(VM_KERN_MEMORY_KALLOC))

        public static let compressor = Self(
            name: "compressor", rawValue: UInt16(VM_KERN_MEMORY_COMPRESSOR)
        )

        public static let compressedData = Self(
            name: "compressedData", rawValue: UInt16(VM_KERN_MEMORY_COMPRESSED_DATA)
        )

        public static let phantomCache = Self(
            name: "phantomCache", rawValue: UInt16(VM_KERN_MEMORY_PHANTOM_CACHE)
        )

        public static let waitq = Self(name: "waitq", rawValue: UInt16(VM_KERN_MEMORY_WAITQ))

        public static let diag = Self(name: "diag", rawValue: UInt16(VM_KERN_MEMORY_DIAG))

        public static let log = Self(name: "log", rawValue: UInt16(VM_KERN_MEMORY_LOG))

        public static let file = Self(name: "file", rawValue: UInt16(VM_KERN_MEMORY_FILE))

        public static let mbuf = Self(name: "mbuf", rawValue: UInt16(VM_KERN_MEMORY_MBUF))

        public static let ubc = Self(name: "ubc", rawValue: UInt16(VM_KERN_MEMORY_UBC))

        public static let security = Self(
            name: "security", rawValue: UInt16(VM_KERN_MEMORY_SECURITY)
        )

        public static let mlock = Self(name: "mlock", rawValue: UInt16(VM_KERN_MEMORY_MLOCK))

        public static let reason = Self(name: "reason", rawValue: UInt16(VM_KERN_MEMORY_REASON))

        public static let skywalk = Self(name: "skywalk", rawValue: UInt16(VM_KERN_MEMORY_SKYWALK))

        public static let ltable = Self(name: "ltable", rawValue: UInt16(VM_KERN_MEMORY_LTABLE))

        public static let hv = Self(name: "hv", rawValue: UInt16(VM_KERN_MEMORY_HV))

        public static let kallocData = Self(
            name: "kallocData", rawValue: UInt16(VM_KERN_MEMORY_KALLOC_DATA)
        )

        public static let retired = Self(name: "retired", rawValue: UInt16(VM_KERN_MEMORY_RETIRED))

        public static let kallocType = Self(
            name: "kallocType", rawValue: UInt16(VM_KERN_MEMORY_KALLOC_TYPE))

        public static let triage = Self(name: "triage", rawValue: UInt16(VM_KERN_MEMORY_TRIAGE))

        public static let recount = Self(name: "recount", rawValue: UInt16(VM_KERN_MEMORY_RECOUNT))

        public static let exclaves = Self(
            name: "exclaves", rawValue: UInt16(VM_KERN_MEMORY_EXCLAVES)
        )
    }

    // MARK: - Counters
    /// A type of memory counter.
    public struct MemoryInfoCounterType: Mach.OptionEnum, Mach.NamedOptionEnum {
        /// Represents a counter type with an optional name and a raw value.
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
    public var tagValue: Mach.MemoryInfoTag? {
        guard self.infoType == .tag else { return nil }
        return Mach.MemoryInfoTag(rawValue: UInt16(self.tag))
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

// MARK: - mach_zone_name
extension mach_zone_name {
    public var nameString: String? {
        let maybeName = withUnsafePointer(to: self.mzn_name) {
            pointer in
            pointer.withMemoryRebound(
                to: CChar.self,
                capacity: Int(MACH_ZONE_NAME_MAX_LEN)
            ) { String(cString: $0) }
        }
        return maybeName != "" ? maybeName : nil
    }
}

// MARK: - Zone
extension Mach {
    /// A zone.
    /// - Note: For historical reasons, the zone name type is a separate type from the zone info.
    public struct Zone {
        public let name: mach_zone_name
        public let info: mach_zone_info_data
    }
}

// MARK: - Functions
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

    /// The zones in the host.
    public var zones: [Mach.Zone] {
        get throws {
            var names: mach_zone_name_array_t?
            var nameCount = mach_msg_type_number_t.max
            var infos: mach_zone_info_array_t?
            var infoCount = mach_msg_type_number_t.max

            try Mach.call(mach_zone_info(self.name, &names, &nameCount, &infos, &infoCount))

            guard nameCount == infoCount else { fatalError("Zone names and infos count mismatch!") }

            return (0..<Int(infoCount)).map {
                // It's not explicitly stated in the documentation, but the arrays should hopefully
                // be the same length and represent the same zones in the same order.
                Mach.Zone(name: names![$0], info: infos![$0])
            }
        }
    }
}
