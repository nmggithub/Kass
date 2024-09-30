import Darwin.Mach

extension Mach.Message.Body.Descriptor {
    /// An iterator for a set of descriptor pointers.
    typealias Manager = Mach.Message.Body.DescriptorManager
}

extension Mach.Message.Body {
    public struct DescriptorManager {
        /// Deserializes a descriptor from a pointer.
        /// - Parameters:
        ///   - type: The type of the descriptor to deserialize.
        ///   - pointer: The pointer to the descriptor.
        /// - Returns: The deserialized descriptor.
        static func deserialize<DescriptorType: Mach.Message.Body.Descriptor>(
            type: DescriptorType.Type,
            from pointer: Mach.Message.Body.Descriptor.Pointer
        ) -> DescriptorType {
            let rawDescriptor = UnsafeRawPointer(pointer).load(as: type.CStruct.self)
            return type.init(rawValue: rawDescriptor)!
        }

        /// Serializes a descriptor to a pointer.
        /// - Parameters:
        ///   - descriptor: The descriptor to serialize.
        ///   - pointer: The pointer to serialize the descriptor to.
        static func serialize(
            descriptor: some Mach.Message.Body.Descriptor,
            to pointer: Mach.Message.Body.Descriptor.Pointer
        ) {
            UnsafeMutableRawPointer(mutating: pointer)
                .storeBytes(of: descriptor.rawValue, as: type(of: descriptor.rawValue))
        }
    }
}
