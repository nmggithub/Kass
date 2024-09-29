import Darwin.Mach

extension Mach {
    /// A type of processor info.
    public struct ProcessorInfoFlavor: RawRepresentable, Hashable, Sendable {
        public let rawValue: processor_flavor_t
        public init(rawValue: processor_flavor_t) { self.rawValue = rawValue }

        public static let basic = Self(rawValue: PROCESSOR_BASIC_INFO)
        public static let cpuLoad = Self(rawValue: PROCESSOR_CPU_LOAD_INFO)
        public static let pmRegisters = Self(rawValue: PROCESSOR_PM_REGS_INFO)
        public static let temperature = Self(rawValue: PROCESSOR_TEMPERATURE)
    }
}

extension Mach.Processor {
    /// Gets the processor's info.
    public func getInfo<DataType: BitwiseCopyable>(
        _ info: Mach.ProcessorInfoFlavor, as type: DataType.Type
    ) throws -> DataType {
        try Mach.callWithCountInOut(type: type) {
            (array: processor_info_t, count) in
            var host_name = self.owningHost.name
            return processor_info(self.name, info.rawValue, &host_name, array, &count)
        }
    }
}
