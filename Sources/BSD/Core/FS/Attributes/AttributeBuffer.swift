import Foundation

extension BSD {
    public struct FSAttributeBuffer {
        /// The buffer pointer.
        public let bufferPointer: UnsafeRawBufferPointer

        /// The advertised length of the buffer.
        public let length: UInt32

        /// The attributes returned in the buffer.
        /// - Important: This is only present if the `.returnedAttributes` attribute was requested.
        public let returnedAttributes: attribute_set_t

        /// Reads the attribute buffer from an attribute list.
        init(_ bufferPointer: UnsafeRawBufferPointer, from list: attrlist) {
            self.bufferPointer = bufferPointer
            guard var walkingPointer = bufferPointer.baseAddress else {
                fatalError("The buffer pointer is nil.")
            }
            self.length = walkingPointer.load(as: UInt32.self)
            walkingPointer += MemoryLayout<UInt32>.size
            self.returnedAttributes =
                list.commonAttributes.contains(.returnedAttributes)
                ? walkingPointer.load(as: attribute_set_t.self)
                : .init()
        }
    }
}
