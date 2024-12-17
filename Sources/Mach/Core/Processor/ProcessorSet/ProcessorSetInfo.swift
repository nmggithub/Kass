import Darwin.Mach
import KassHelpers

extension Mach {
    public struct ProcessorSetInfoFlavor: KassHelpers.OptionEnum {
        /// The raw value of the flavor.
        public let rawValue: Int32

        /// Represents a raw processor set info flavor.
        public init(rawValue: Int32) { self.rawValue = rawValue }

        /// Basic information about a processor set.
        public static let basic = Self(rawValue: PROCESSOR_SET_BASIC_INFO)
    }

    /// A processor set info manager.
    public struct ProcessorSetInfoManager: FlavoredDataGetter {
        /// The processor set.
        internal let processorSet: Mach.ProcessorSet
        /// Creates a processor set info manager.
        public init(processorSet: Mach.ProcessorSet) { self.processorSet = processorSet }

        /// Gets the processor set's info.
        public func get<DataType>(
            _ flavor: Mach.ProcessorSetInfoFlavor, as type: DataType.Type = DataType.self
        ) throws -> DataType where DataType: BitwiseCopyable {
            try Mach.callWithCountInOut(type: type) {
                (array: processor_set_info_t, count) in
                var hostPortName = self.processorSet.owningHost.name
                return processor_set_info(
                    self.processorSet.name, flavor.rawValue, &hostPortName, array, &count
                )
            }
        }
    }
}

extension Mach.ProcessorSet {
    /// The info of the processor set.
    public var info: Mach.ProcessorSetInfoManager { .init(processorSet: self) }
}

extension Mach.ProcessorSetInfoManager {
    /// The processor set's basic information.
    public var basic: processor_set_basic_info {
        get throws { try self.get(.basic) }
    }
}
