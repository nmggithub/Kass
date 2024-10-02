import Darwin.Mach
import MachC.VMStatistics

extension Mach {
    public struct MemoryInfoSiteType: Mach.OptionEnum {
        public var rawValue: UInt8
        public init(rawValue: UInt8) { self.rawValue = rawValue }

        public static let tag = Self(rawValue: UInt8(VM_KERN_SITE_TAG))

        public static let kmod = Self(rawValue: UInt8(VM_KERN_SITE_KMOD))

        public static let kernel = Self(rawValue: UInt8(VM_KERN_SITE_KERNEL))

        public static let counter = Self(rawValue: UInt8(VM_KERN_SITE_COUNTER))
    }

    public struct MemoryInfoTag: Mach.OptionEnum {
        public var rawValue: UInt16
        public init(rawValue: UInt16) { self.rawValue = rawValue }

        public static let none = Self(rawValue: UInt16(VM_KERN_MEMORY_NONE))

        public static let osfmk = Self(rawValue: UInt16(VM_KERN_MEMORY_OSFMK))

        public static let bsd = Self(rawValue: UInt16(VM_KERN_MEMORY_BSD))

        public static let iokit = Self(rawValue: UInt16(VM_KERN_MEMORY_IOKIT))

        public static let libkern = Self(rawValue: UInt16(VM_KERN_MEMORY_LIBKERN))

        public static let oskext = Self(rawValue: UInt16(VM_KERN_MEMORY_OSKEXT))

        public static let kext = Self(rawValue: UInt16(VM_KERN_MEMORY_KEXT))

        public static let ipc = Self(rawValue: UInt16(VM_KERN_MEMORY_IPC))

        public static let stack = Self(rawValue: UInt16(VM_KERN_MEMORY_STACK))

        public static let cpu = Self(rawValue: UInt16(VM_KERN_MEMORY_CPU))

        public static let pmap = Self(rawValue: UInt16(VM_KERN_MEMORY_PMAP))

        public static let pte = Self(rawValue: UInt16(VM_KERN_MEMORY_PTE))

        public static let zone = Self(rawValue: UInt16(VM_KERN_MEMORY_ZONE))

        public static let kalloc = Self(rawValue: UInt16(VM_KERN_MEMORY_KALLOC))

        public static let compressor = Self(rawValue: UInt16(VM_KERN_MEMORY_COMPRESSOR))

        public static let compressedData = Self(rawValue: UInt16(VM_KERN_MEMORY_COMPRESSED_DATA))

        public static let phantomCache = Self(rawValue: UInt16(VM_KERN_MEMORY_PHANTOM_CACHE))

        public static let waitq = Self(rawValue: UInt16(VM_KERN_MEMORY_WAITQ))

        public static let diag = Self(rawValue: UInt16(VM_KERN_MEMORY_DIAG))

        public static let log = Self(rawValue: UInt16(VM_KERN_MEMORY_LOG))

        public static let file = Self(rawValue: UInt16(VM_KERN_MEMORY_FILE))

        public static let mbuf = Self(rawValue: UInt16(VM_KERN_MEMORY_MBUF))

        public static let ubc = Self(rawValue: UInt16(VM_KERN_MEMORY_UBC))

        public static let security = Self(rawValue: UInt16(VM_KERN_MEMORY_SECURITY))

        public static let mlock = Self(rawValue: UInt16(VM_KERN_MEMORY_MLOCK))

        public static let reason = Self(rawValue: UInt16(VM_KERN_MEMORY_REASON))

        public static let skywalk = Self(rawValue: UInt16(VM_KERN_MEMORY_SKYWALK))

        public static let ltable = Self(rawValue: UInt16(VM_KERN_MEMORY_LTABLE))

        public static let hv = Self(rawValue: UInt16(VM_KERN_MEMORY_HV))

        public static let kallocData = Self(rawValue: UInt16(VM_KERN_MEMORY_KALLOC_DATA))

        public static let retired = Self(rawValue: UInt16(VM_KERN_MEMORY_RETIRED))

        public static let kallocType = Self(rawValue: UInt16(VM_KERN_MEMORY_KALLOC_TYPE))

        public static let triage = Self(rawValue: UInt16(VM_KERN_MEMORY_TRIAGE))

        public static let recount = Self(rawValue: UInt16(VM_KERN_MEMORY_RECOUNT))

        public static let exclaves = Self(rawValue: UInt16(VM_KERN_MEMORY_EXCLAVES))
    }

    public struct MemoryInfoCountType: Mach.OptionEnum {
        public var rawValue: UInt64
        public init(rawValue: UInt64) { self.rawValue = rawValue }

        public static let managed = Self(rawValue: UInt64(VM_KERN_COUNT_MANAGED))

        public static let reserved = Self(rawValue: UInt64(VM_KERN_COUNT_RESERVED))

        public static let wired = Self(rawValue: UInt64(VM_KERN_COUNT_WIRED))

        public static let wiredManaged = Self(rawValue: UInt64(VM_KERN_COUNT_WIRED_MANAGED))

        public static let stolen = Self(rawValue: UInt64(VM_KERN_COUNT_STOLEN))

        public static let loPage = Self(rawValue: UInt64(VM_KERN_COUNT_LOPAGE))

        public static let mapZone = Self(rawValue: UInt64(VM_KERN_COUNT_MAP_ZONE))

        public static let mapKernel = Self(rawValue: UInt64(VM_KERN_COUNT_MAP_KERNEL))

        public static let mapKalloc = Self(rawValue: UInt64(VM_KERN_COUNT_MAP_KALLOC))

        public static let wiredBoot = Self(rawValue: UInt64(VM_KERN_COUNT_WIRED_BOOT))

        public static let bootStolen = Self(rawValue: UInt64(VM_KERN_COUNT_BOOT_STOLEN))

        public static let wiredStaticKernelcache = Self(
            rawValue: UInt64(VM_KERN_COUNT_WIRED_STATIC_KERNELCACHE))

        public static let mapKallocLargeData = Self(
            rawValue: UInt64(VM_KERN_COUNT_MAP_KALLOC_LARGE_DATA))

        public static let mapKernelData = Self(rawValue: UInt64(VM_KERN_COUNT_MAP_KERNEL_DATA))
    }
}

extension mach_memory_info {
    public var nameString: String {
        withUnsafePointer(to: self.name) {
            pointer in
            pointer.withMemoryRebound(
                to: CChar.self,
                capacity: Int(MACH_MEMORY_INFO_NAME_MAX_LEN)
            ) { String(cString: $0) }
        }
    }

    public var siteType: Mach.MemoryInfoSiteType {
        Mach.MemoryInfoSiteType(rawValue: UInt8(self.flags & UInt64(VM_KERN_SITE_TYPE)))
    }

    public var tagValue: Mach.MemoryInfoTag? {
        guard self.siteType == .tag else { return nil }
        return Mach.MemoryInfoTag(rawValue: UInt16(self.tag))
    }

    public var counterType: Mach.MemoryInfoCountType? {
        guard self.siteType == .counter else { return nil }
        return Mach.MemoryInfoCountType(rawValue: self.site)
    }
}

extension Mach.VM {
    /// Gets the allocation sites in a host.
    public static func allocationSites(in host: Mach.Host = .current) throws -> [mach_memory_info] {
        // These are ignored, but required by the kernel call.
        var names: mach_zone_name_array_t?
        var nameCount = mach_msg_type_number_t.max
        var infos: mach_zone_info_array_t?
        var infoCount = mach_msg_type_number_t.max

        var memoryInfos: mach_memory_info_array_t?
        var memoryInfoCount = mach_msg_type_number_t.max
        try Mach.call(
            mach_memory_info(
                host.name, &names, &nameCount, &infos, &infoCount,
                &memoryInfos, &memoryInfoCount
            )
        )
        return (0..<Int(memoryInfoCount)).map { memoryInfos![$0] }
    }
}
