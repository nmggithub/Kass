import Darwin.Mach
import KassHelpers

extension Mach {
    /// A flavor of processor info.
    public struct ProcessorInfoFlavor: KassHelpers.OptionEnum {
        /// The raw value of the flavor.
        public let rawValue: processor_flavor_t

        /// Represents a raw processor info flavor.
        public init(rawValue: processor_flavor_t) { self.rawValue = rawValue }

        /// Basic information about a processor.
        public static let basic = Self(rawValue: PROCESSOR_BASIC_INFO)

        /// CPU load information for a processor.
        public static let cpuLoad = Self(rawValue: PROCESSOR_CPU_LOAD_INFO)
    }

    /// A processor info manager.
    public struct ProcessorInfoManager: FlavoredDataGetter {
        /// The processor.
        public let processor: Mach.Processor

        /// Creates a processor info manager.
        public init(processor: Mach.Processor) { self.processor = processor }

        /// Gets the processor's info.
        public func get<DataType>(
            _ flavor: Mach.ProcessorInfoFlavor, as type: DataType.Type = DataType.self
        ) throws -> DataType where DataType: BitwiseCopyable {
            try Mach.callWithCountInOut(type: type) {
                (array: processor_info_t, count) in
                var hostName = self.processor.owningHost.name
                return processor_info(
                    self.processor.name, flavor.rawValue, &hostName, array, &count)
            }
        }
    }
}

extension Mach.Processor {
    /// The info of the processor.
    public var info: Mach.ProcessorInfoManager { .init(processor: self) }
}

extension Mach.ProcessorInfoManager {

    // See ProcessorBasicInfo.swift for the ProcessorBasicInfo struct and implementation.

    /// The processor's CPU load information.
    public var cpuLoad: processor_cpu_load_info {
        get throws { try self.get(.cpuLoad) }
    }
}
