import Darwin.Mach
import MachBase

extension Mach.Message {
    /// A body of descriptors.
    public struct Body {
        /// A pointer to the raw body.
        public var rawValue: UnsafeMutablePointer<mach_msg_body_t> {
            let rawPointer = UnsafeMutableRawPointer.allocate(
                byteCount: self.totalSize,
                alignment: MemoryLayout<mach_msg_body_t>.alignment
            )
            rawPointer.initializeMemory(as: UInt8.self, repeating: 0, count: self.totalSize)
            let bodyPointer = rawPointer.bindMemory(to: mach_msg_body_t.self, capacity: 1)
            bodyPointer.pointee.msgh_descriptor_count = self.descriptorCount
            var descriptorPointer = (rawPointer + MemoryLayout<mach_msg_body_t>.size)
                .bindMemory(to: mach_msg_type_descriptor_t.self, capacity: 1)
            for descriptor in self.descriptors {
                Mach.Message.Body.Descriptor.Manager.serialize(
                    descriptor: descriptor, to: descriptorPointer)
                descriptorPointer = (UnsafeMutableRawPointer(descriptorPointer) + descriptor.size)
                    .bindMemory(to: mach_msg_type_descriptor_t.self, capacity: 1)
            }
            return bodyPointer
        }
        /// Represent an existing raw body.
        /// - Parameter rawValue: A pointer to the raw body.
        public init(rawValue: UnsafeMutablePointer<mach_msg_body_t>) {
            self.descriptorCount = rawValue.pointee.msgh_descriptor_count
            var descriptors: [any Mach.Message.Body.Descriptor] = []
            var iterator = Mach.Message.Body.Descriptor.Iterator(bodyPointer: rawValue)
            while let descriptorPointer = iterator.next() {
                let descriptorType = Mach.Message.Body.DescriptorType(
                    rawValue: descriptorPointer.pointee.type
                )!
                let descriptor = Mach.Message.Body.DescriptorManager.deserialize(
                    type: descriptorType.swiftStructType, from: descriptorPointer
                )
                descriptors.append(descriptor)
            }
            self.descriptors = descriptors
        }
        /// The number of descriptors in the body.
        /// - Warning: While this property is writable, it is not recommended to change it from the actual number of descriptors.
        public var descriptorCount: mach_msg_size_t
        /// The descriptors in the body.
        public var descriptors: [any Mach.Message.Body.Descriptor] {
            didSet {
                self.descriptorCount = mach_msg_size_t(self.descriptors.count)
            }
        }
        /// The total size of the body in bytes.
        public var totalSize: Int {
            MemoryLayout<mach_msg_body_t>.size + self.descriptors.reduce(0) { $0 + $1.size }
        }

        /// Create a new message body with a list of descriptors.
        /// - Parameter descriptors: The descriptors.
        public init(descriptors: [any Mach.Message.Body.Descriptor]) {
            self.descriptorCount = mach_msg_size_t(descriptors.count)
            self.descriptors = descriptors
        }
    }
}
