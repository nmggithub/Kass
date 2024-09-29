import Darwin.Mach

extension Mach {
    public struct ProcessorSetInfoFlavor: OptionEnum {
        public let rawValue: Int32
        public init(rawValue: Int32) { self.rawValue = rawValue }

        /// Basic information about a processor set.
        public static let basic = Self(rawValue: PROCESSOR_SET_BASIC_INFO)
    }
}

extension Mach.ProcessorSet {
    /// Gets the processor set's info.
    public func getInfo<DataType: BitwiseCopyable>(
        _ flavor: Mach.ProcessorSetInfoFlavor, as type: DataType.Type = DataType.self
    ) throws -> DataType {
        try Mach.callWithCountInOut(type: type) {
            (array: processor_set_info_t, count) in
            var hostPortName = self.owningHost.name
            return processor_set_info(self.name, flavor.rawValue, &hostPortName, array, &count)
        }
    }
}

extension Mach.ProcessorSet {
    /// The processor set's basic information.
    public var basicInfo: processor_set_basic_info {
        get throws { try self.getInfo(.basic) }
    }
}
