import Darwin.Mach

extension Mach.VM {
    /// A zone.
    /// - Warning: Some properties are only available from privileged processes.
    public struct Zone {
        /// The name of the zone.
        public let name: String
        /// The number of elements in the zone.
        public let elementCount: UInt64
        /// The size of an element in the zone.
        public let elementSize: UInt64
        /// The current size of the zone.
        public let currentSize: UInt64
        /// The maximum size of the zone.
        public let maxSize: UInt64
        /// The allocation size for the zone.
        public let allocationSize: UInt64
        /// The sum of all allocations in the zone.
        public let sumSize: UInt64
        /// Whether the zone is exhaustible.
        public let exhaustible: Bool
        /// Whether the zone can be garbage-collected.
        public let collectable: Bool
        /// The size, in bytes, that can be garbage-collected.
        public let collectableBytes: UInt64
        public init(name: String, info: mach_zone_info_t) {
            self.name = name
            self.elementCount = info.mzi_count
            self.elementSize = info.mzi_elem_size
            self.currentSize = info.mzi_cur_size
            self.maxSize = info.mzi_max_size
            self.allocationSize = info.mzi_alloc_size
            self.sumSize = info.mzi_sum_size
            self.exhaustible = info.mzi_exhaustible != 0
            self.collectable = info.mzi_collectable & 1 != 0
            self.collectableBytes = info.mzi_collectable >> 1
        }
    }

    /// Get the zones in a host.
    /// - Parameter host: The host to get the zones for.
    /// - Throws: If the zones cannot be retrieved.
    /// - Returns: The zones in the host.
    public static func zones(in host: Mach.Host = .current) throws -> [Zone] {
        var names: mach_zone_name_array_t?
        var nameCount = mach_msg_type_number_t.max
        var infos: mach_zone_info_array_t?
        var infoCount = mach_msg_type_number_t.max
        try Mach.Call(mach_zone_info(host.name, &names, &nameCount, &infos, &infoCount))
        guard nameCount == infoCount else {
            fatalError("Kernel returned mismatched zone name and info counts!")
        }
        return (0..<Int(nameCount)).map {
            let name = withUnsafePointer(to: names![$0].mzn_name) {
                pointer in
                // The MACH_ZONE_NAME_MAX_LEN macro also exists. However, as of writing, the kernel uses the ZONE_NAME_MAX_LEN
                // constant instead to define the size of the `mzn_name` field in `mach_zone_name_t`, so we use that. Both are
                // currently the same value, so it shouldn't really matter which one we use, but we want to be consistent with
                // the kernel (even if what we're copying is likely a bug).
                pointer.withMemoryRebound(to: CChar.self, capacity: Int(ZONE_NAME_MAX_LEN)) {
                    String(cString: $0)
                }
            }
            return Zone(name: name, info: infos![$0])
        }
    }
}
