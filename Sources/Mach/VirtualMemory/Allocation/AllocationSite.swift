import Darwin.Mach

extension Mach.VM {
    /// Information about an allocation site.
    public class AllocationSite: RawRepresentable {
        /// The raw information about the allocation site.
        public let rawValue: mach_memory_info_t
        /// Represent the allocation site with the given raw information.
        /// - Parameter rawValue: The raw information about the allocation site.
        public required init(rawValue: mach_memory_info_t) {
            self.rawValue = rawValue
        }
        /// A type of allocation site.
        public enum SiteType: UInt8 {
            case unknown = 0xFF
            case tag = 0
            case kmod = 1
            case kernel = 2
            case counter = 3
        }
        /// The name of the allocation site.
        public var name: String {
            withUnsafePointer(to: self.rawValue.name) {
                pointer in
                pointer.withMemoryRebound(
                    to: CChar.self,
                    capacity: Int(MACH_MEMORY_INFO_NAME_MAX_LEN)
                ) { String(cString: $0) }
            }
        }
        /// The type of the allocation site.
        public var type: SiteType {
            SiteType(rawValue: UInt8(rawValue.flags & 0xFF)) ?? .unknown
        }
        /// The size of the allocation site.
        public var size: UInt64 { rawValue.size }
    }

    /// Information about an allocation site with a tag.
    public class TaggedAllocationSite: AllocationSite {
        /// An allocation site tag.
        public enum Tag: UInt16 {  // vm_tag_t in the kernel
            case unknown = 0xFFFF
            case none = 0
            case osfmk = 1
            case bsd = 2
            case iokit = 3
            case libkern = 4
            case oskext = 5
            case kext = 6
            case ipc = 7
            case stack = 8
            case cpu = 9
            case pmap = 10
            case pte = 11
            case zone = 12
            case kalloc = 13
            case compressor = 14
            case compressedData = 15
            case phantomCache = 16
            case waitq = 17
            case diag = 18
            case log = 19
            case file = 20
            case mbuf = 21
            case ubc = 22
            case security = 23
            case mlock = 24
            case reason = 25
            case skywalk = 26
            case ltable = 27
            case hv = 28
            case kallocData = 29
            case retired = 30
            case kallocType = 31
            case triage = 32
            case recount = 33
            // where is 34?
            case exclaves = 35
        }
        /// The tag for the allocation site.
        public var tag: Tag {
            Tag(rawValue: rawValue.tag) ?? .unknown
        }
    }

    /// Information about an "allocation site" that's actually a counter.
    public class CounterAllocationSite: AllocationSite {
        /// A type of counter.
        public enum CounterType: UInt64 {
            case unknown = 0xFFFF
            case managed = 0
            case reserved = 1
            case wired = 2
            case wiredManaged = 3
            case stolen = 4
            case loPage = 5
            case mapZone = 6
            case mapKernel = 7
            case mapKalloc = 8
            case wiredBoot = 9
            case bootStolen = 10
            case wiredStaticKernelcache = 11
            // these last two don't appear to be used
            case mapKallocLargeData = 12
            case mapKernelData = 13
        }
        /// The type of the counter.
        public var counterType: CounterType {
            CounterType(rawValue: rawValue.site) ?? .unknown
        }
        public var free: UInt64 { rawValue.free }
        public var mapped: UInt64 { rawValue.mapped }
    }

    /// Get the allocation sites in a host.
    /// - Parameter host: The host to get the allocation sites for.
    /// - Throws: If the allocation sites cannot be retrieved.
    /// - Returns: The allocation sites in the host.
    public static func allocationSites(in host: Mach.Host = .current) throws -> [AllocationSite] {
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
        return (0..<Int(memoryInfoCount)).map {
            let site = AllocationSite(rawValue: memoryInfos![$0])
            return switch site.type {
            case .tag: TaggedAllocationSite(rawValue: site.rawValue)
            case .counter: CounterAllocationSite(rawValue: site.rawValue)
            default: site
            }
        }
    }
}
