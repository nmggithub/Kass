import Foundation

extension BSD.FS.Attribute {
    public struct Buffer {
        /// The buffer pointer.
        public let bufferPointer: UnsafeRawBufferPointer
        /// The advertised length of the buffer.
        public let length: UInt32
        /// The attributes returned in the buffer.
        /// - Important: This is only present if the `.returnedAttributes` attribute was requested.
        public let returnedAttributes: BSD.FS.Attribute.Set

        /// Reads the attribute buffer from an attribute list.
        /// - Parameters:
        ///   - bufferPointer: The pointer to the buffer.
        ///   - list: The attribute list that was used to get the buffer.
        init(_ bufferPointer: UnsafeRawBufferPointer, from list: List) {
            self.bufferPointer = bufferPointer
            guard var walkingPointer = bufferPointer.baseAddress else {
                fatalError("The buffer pointer is nil.")
            }
            self.length = walkingPointer.load(as: UInt32.self)
            walkingPointer += MemoryLayout<UInt32>.size
            self.returnedAttributes =
                list.common.contains(.returnedAttributes)
                ? .init(rawValue: walkingPointer.load(as: attribute_set_t.self))
                : .init()
        }
    }
}
