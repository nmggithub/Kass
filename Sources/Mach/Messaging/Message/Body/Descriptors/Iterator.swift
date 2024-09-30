import Darwin.Mach
import Foundation

extension Mach.Message.Body.Descriptor {
    /// An iterator for a set of descriptor pointers.
    typealias Iterator = Mach.Message.Body.DescriptorIterator
}

extension Mach.Message.Body {
    /// An iterator for a set of descriptor pointers.
    public struct DescriptorIterator: IteratorProtocol {
        public typealias Element = Descriptor.Pointer
        /// The count of descriptors.
        private let count: Int
        /// The current index.
        private var index: Int = 0
        /// The current descriptor pointer.
        private var pointer: Descriptor.Pointer
        /// Creates an iterator for a set of descriptor pointers.
        /// - Parameter bodyPointer: A pointer to a message body.
        init(bodyPointer: UnsafePointer<mach_msg_body_t>) {
            self.count = Int(bodyPointer.pointee.msgh_descriptor_count)
            self.pointer = UnsafeRawPointer(bodyPointer + 1)
                .bindMemory(to: mach_msg_type_descriptor_t.self, capacity: 1)
        }
        /// Gets the next descriptor pointer.
        /// - Returns: The next descriptor pointer, or `nil` if there are no more descriptors.
        /// - Warning: This method also returns `nil` if the type of the next descriptor is invalid.
        public mutating func next() -> Descriptor.Pointer? {
            guard self.index < self.count else { return nil }  // No more descriptors.
            let rawDescriptorType = self.pointer.pointee.type
            guard
                let descriptorType = Mach.Message.Body.DescriptorType(
                    rawValue: rawDescriptorType
                )
            else { return nil }  // Invalid descriptor type.
            let descriptorPointer = self.pointer
            self.pointer = (UnsafeRawPointer(self.pointer) + descriptorType.swiftStructType.size)
                .bindMemory(to: mach_msg_type_descriptor_t.self, capacity: 1)
            self.index += 1
            return descriptorPointer
        }
    }
}
