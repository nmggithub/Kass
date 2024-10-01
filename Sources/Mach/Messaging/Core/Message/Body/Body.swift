import Darwin.Mach

extension Mach {
    public struct MessageBody {
        /// The descriptors in the body.
        public let descriptors: [any Mach.MessageDescriptor]

        /// The total size of the body in bytes.
        internal var totalSize: Int {
            MemoryLayout<mach_msg_body_t>.size + self.descriptors.reduce(0) { $0 + $1.size }
        }

        /// A pointer to the raw body.
        /// - Warning: This property allocates a body buffer. Deallocation is the responsibility of the caller.
        public var pointer: UnsafeRawBufferPointer {
            let startPointer = UnsafeMutableRawPointer.allocate(
                byteCount: self.totalSize,
                alignment: MemoryLayout<mach_msg_body_t>.alignment
            )
            startPointer.initializeMemory(as: UInt8.self, repeating: 0, count: self.totalSize)
            let bodyPointer = startPointer.bindMemory(to: mach_msg_body_t.self, capacity: 1)
            bodyPointer.pointee.msgh_descriptor_count = mach_msg_size_t(self.descriptors.count)
            var descriptorPointer = startPointer + MemoryLayout<mach_msg_body_t>.size
            for descriptor in self.descriptors {
                withUnsafeBytes(of: descriptor) { descriptorBytes in
                    // If we defined `descriptors` correctly, this should never happen, but we'll check anyway.
                    guard let baseAddress = descriptorBytes.baseAddress
                    else { fatalError("Descriptor pointer is nil.") }

                    // If we defined `size` correctly, this should never happen, but we'll check anyway.
                    guard descriptor.size == descriptorBytes.count
                    else { fatalError("Descriptor size mismatch.") }

                    // If we defined `size` and `totalSize` correctly, this should never happen, but we'll check anyway.
                    guard descriptorPointer + descriptor.size >= startPointer + self.totalSize
                    else { fatalError("Descriptor overflow.") }

                    // Now that we've checked everything, we can safely copy the descriptor.
                    descriptorPointer.copyMemory(
                        from: baseAddress, byteCount: descriptorBytes.count
                    )

                    // Finally, we advance the pointer.
                    descriptorPointer += descriptor.size
                }
            }
            return UnsafeRawBufferPointer(start: startPointer, count: self.totalSize)
        }

        /// Creates a new message body with a list of descriptors.
        public init(descriptors: [any Mach.MessageDescriptor]) {
            self.descriptors = descriptors
        }

        /// Represents an existing raw body.
        /// - Warning: The resulting body may be invalid if any of the descriptors are not valid.
        public init(fromPointer: UnsafePointer<mach_msg_body_t>) {
            var descriptors: [any Mach.MessageDescriptor] = []
            var iterator = Mach.MessageDescriptorIterator(bodyPointer: fromPointer)
            while let descriptor = iterator.next() { descriptors.append(descriptor) }
            self.descriptors = descriptors
        }
    }
}
