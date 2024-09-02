import Foundation
import MachO

/// A pointer to a Mach message descriptor.
/// - Note: All Mach message descriptors can be cast to `mach_msg_type_descriptor_t` to get the type.
internal typealias MachMessageDescriptorPointer = UnsafePointer<mach_msg_type_descriptor_t>

/// An iterator for a set of descriptor pointers.
internal struct MachMessageDescriptorIterator: IteratorProtocol {
    typealias Element = MachMessageDescriptorPointer
    /// The current index.
    private var index: Int = 0
    /// The current descriptor pointer.
    private var pointer: MachMessageDescriptorPointer
    /// Create an iterator for a set of descriptor pointers.
    /// - Parameter bodyPointer: A pointer to a message body.
    init(bodyPointer: UnsafePointer<mach_msg_body_t>) {
        self.pointer = UnsafeRawPointer(bodyPointer + 1)
            .bindMemory(to: mach_msg_type_descriptor_t.self, capacity: 1)
    }
    /// Get the next descriptor pointer.
    /// - Returns: The next descriptor pointer, or `nil` if there are no more descriptors.
    /// - Warning: This method also returns `nil` if the type of the next descriptor is invalid.
    mutating func next() -> MachMessageDescriptorPointer? {
        let rawDescriptorType = self.pointer.pointee.type
        guard let descriptorType = MachMessageDescriptor.DescriptorType(rawValue: rawDescriptorType)
        else { return nil }  // Invalid descriptor type.
        let descriptorPointer = self.pointer
        self.pointer = (UnsafeRawPointer(self.pointer) + descriptorType.swiftStructType.size)
            .bindMemory(to: mach_msg_type_descriptor_t.self, capacity: 1)
        return descriptorPointer
    }
}

/// A helper for serializing and deserializing descriptors.
internal struct MachMessageDescriptorManager {
    /// Deserialize a descriptor from a pointer.
    /// - Parameters:
    ///   - type: The type of the descriptor to deserialize.
    ///   - pointer: The pointer to the descriptor.
    /// - Returns: The deserialized descriptor.
    static func deserialize<DescriptorType: MachMessageDescriptor>(
        type: DescriptorType.Type,
        from pointer: MachMessageDescriptorPointer
    ) -> DescriptorType {
        let rawDescriptor = UnsafeRawPointer(pointer).load(as: type.CStruct.self)
        return type.init(rawValue: rawDescriptor)!
    }

    /// Serialize a descriptor to a pointer.
    /// - Parameters:
    ///   - descriptor: The descriptor to serialize.
    ///   - pointer: The pointer to serialize the descriptor to.
    static func serialize(
        descriptor: some MachMessageDescriptor,
        to pointer: MachMessageDescriptorPointer
    ) {
        UnsafeMutableRawPointer(mutating: pointer)
            .storeBytes(of: descriptor.rawValue, as: type(of: descriptor.rawValue))
    }
}
