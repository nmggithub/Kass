import Darwin.Mach

extension Mach {
    /// A flavor of processor info.
    public struct ProcessorInfoFlavor: OptionEnum {
        public let rawValue: processor_flavor_t
        public init(rawValue: processor_flavor_t) { self.rawValue = rawValue }

        /// Basic information about a processor.
        public static let basic = Self(rawValue: PROCESSOR_BASIC_INFO)

        /// CPU load information for a processor.
        public static let cpuLoad = Self(rawValue: PROCESSOR_CPU_LOAD_INFO)
    }
}

extension Mach.Processor {
    /// Gets the processor's info.
    public func getInfo<DataType: BitwiseCopyable>(
        _ flavor: Mach.ProcessorInfoFlavor, as type: DataType.Type
    ) throws -> DataType {
        try Mach.callWithCountInOut(type: type) {
            (array: processor_info_t, count) in
            var host_name = self.owningHost.name
            return processor_info(self.name, flavor.rawValue, &host_name, array, &count)
        }
    }
}

extension Mach.Processor {

    // See ProcessorBasicInfo.swift for the ProcessorBasicInfo struct and implementation.

    /// The processor's CPU load information.
    public var cpuLoadInfo: processor_cpu_load_info {
        get throws { try getInfo(.cpuLoad, as: processor_cpu_load_info.self) }
    }
}
