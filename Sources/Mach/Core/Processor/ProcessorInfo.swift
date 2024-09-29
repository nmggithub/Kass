import Darwin.Mach

extension Mach {
    /// A type of processor info.
    public enum ProcessorInfoFlavor: processor_flavor_t {
        case basic = 1
        case cpuLoad = 2
        case pmRegisters = 0x1000_0001
        case temperature = 0x1000_0002
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
