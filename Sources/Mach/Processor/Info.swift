import Darwin.Mach

extension Mach.Host.Processor {
    /// Information about the processor.
    public var info: Info { Info(for: self, in: owningHost) }
    /// Information about a processor.
    public class Info: Mach.FlavoredDataManagerNoAdditionalArgs<
        Info.Flavor, processor_info_t.Pointee
    >
    {
        /// Create a new processor info manager.
        /// - Parameters:
        ///   - processor: The processor to get information about.
        ///   - host: The host that the processor is in.
        public convenience init(for processor: Mach.Host.Processor, in host: Mach.Host) {
            self.init(
                getter: {
                    flavor, info, count, _ in
                    var host_name = host.name
                    return processor_info(
                        processor.name, flavor.rawValue,
                        &host_name, info, &count
                    )
                },
                setter: {
                    _, _, _, _ in
                    fatalError("Processor info cannot be set.")
                })
        }
        /// A flavor of processor information.
        public enum Flavor: processor_flavor_t {
            case basic = 1
            case cpuLoad = 2
            case pmRegisters = 0x1000_0001
            case temperature = 0x1000_0002
        }

        /// Get a processor's info.
        /// - Parameters:
        ///   - flavor: The flavor of the info.
        ///   - type: The type to load the info as.
        /// - Throws: An error if the info cannot be retrieved.
        /// - Returns: The processor's info.
        public func get<InfoType>(_ flavor: Flavor, as type: InfoType.Type) throws
            -> InfoType
        {
            try super.get(flavor, as: type)
        }

        @available(*, unavailable, message: "Setting processor info is not supported.")
        public override func set<DataType>(
            _ flavor: Flavor, to value: consuming DataType, additional: Never? = nil
        ) throws {}
    }
}
