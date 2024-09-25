import Darwin.Mach

extension Mach.Processor {
    /// A type of processor info.
    public enum Info: processor_flavor_t {
        case basic = 1
        case cpuLoad = 2
        case pmRegisters = 0x1000_0001
        case temperature = 0x1000_0002
    }

    /// Gets the processor's info.
    /// - Parameters:
    ///   - info: The info to get.
    ///   - type: The type to load the info as.
    /// - Throws: An error if the info cannot be retrieved.
    /// - Returns: The info.
    public func getInfo<DataType: BitwiseCopyable>(
        _ info: Info, as type: DataType.Type
    ) throws -> DataType {
        try Mach.callWithCountInOut(type: type) {
            (array: processor_info_t, count) in
            var host_name = self.owningHost.name
            return processor_info(self.name, info.rawValue, &host_name, array, &count)
        }
    }
}
