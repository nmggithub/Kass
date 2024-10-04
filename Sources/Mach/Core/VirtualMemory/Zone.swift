import Darwin.Mach

extension mach_zone_name {
    /// The name of the zone.
    public var nameString: String? {
        let maybeName = withUnsafePointer(to: self.mzn_name) {
            pointer in
            pointer.withMemoryRebound(
                to: CChar.self,
                // While the MACH_ZONE_NAME_MAX_LEN macro also exists, at the time of writing of writing, the kernel
                // chooses to instead use the ZONE_NAME_MAX_LEN macro to define the length of `mzn_name`. While both
                // are currently the same value, but they are defined independently. To ensure compatibility, we use
                // what the kernel uses (even though it's likely a bug).
                capacity: Int(ZONE_NAME_MAX_LEN)
            ) { String(cString: $0) }
        }
        return maybeName != "" ? maybeName : nil
    }
}

extension Mach {
    /// A zone.
    /// - Note: For historical reasons, the zone name type is a separate type from the zone info.
    public struct Zone {
        public let name: mach_zone_name
        public let info: mach_zone_info_data
    }
}

extension Mach.Host {
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
