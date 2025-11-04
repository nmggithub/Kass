import Darwin.Mach
import Foundation

extension Mach {
    /// A segment of a message payload.
    public protocol MessagePayloadSegment {
        /// Converts the payload segment to a raw buffer.
        func toRawBuffer() -> UnsafeRawBufferPointer
    }

    /// A message payload with multiple contiguous segments.
    /// - Warning: This cannot be used with received payloads, as the original element types cannot be recovered.
    public struct MessagePayloadWithSegments: Mach.MessagePayload {
        /// The segments of the payload.
        public var segments: [Mach.MessagePayloadSegment]

        /// Initializes a payload with the given segments.
        public init(_ segments: [Mach.MessagePayloadSegment]) {
            self.segments = segments
        }

        public static func fromRawPayloadBuffer(_ buffer: UnsafeRawBufferPointer)
            -> Mach.MessagePayloadWithSegments?
        {
            /// We cannot recover the original segments from the raw buffer, as they could be anything.
            return nil
        }

        public func toRawPayloadBuffer() -> UnsafeRawBufferPointer {
            let buffers = segments.map { $0.toRawBuffer() }
            let resultBuffer = UnsafeMutableRawBufferPointer.allocate(
                byteCount: buffers.reduce(0) { $0 + ($1.count + 3) & ~3 },
                alignment: 4
            )
            var offset = 0
            for buffer in buffers {
                resultBuffer.baseAddress!.advanced(by: offset).copyMemory(
                    from: buffer.baseAddress!,
                    byteCount: buffer.count
                )
                offset += (buffer.count + 3) & ~3
            }
            return UnsafeRawBufferPointer(resultBuffer)
        }
    }

    /// A payload segment with a fixed length and trivial representation.
    public protocol TrivialMessagePayloadSegment: Mach.MessagePayloadSegment, BitwiseCopyable {}

    /// A payload segment representing a variable-length array of trivial elements.
    public struct VariableLengthArrayPayloadSegment<ArrayElement: TrivialMessagePayloadSegment>:
        Mach.MessagePayloadSegment
    {
        public var arrayElements: [ArrayElement]

        public init(_ arrayElements: [ArrayElement]) {
            self.arrayElements = arrayElements
        }

        public func toRawBuffer() -> UnsafeRawBufferPointer {
            let arrayElementSize = MemoryLayout<ArrayElement>.size
            let arrayElementCount = arrayElements.count
            let bufferSize =
                MemoryLayout<mach_msg_type_number_t>.size + (arrayElementSize * arrayElementCount)
            let buffer = UnsafeMutableRawBufferPointer.allocate(
                byteCount: bufferSize,
                alignment: 4
            )
            buffer.baseAddress!.assumingMemoryBound(to: mach_msg_type_number_t.self).pointee =
                mach_msg_type_number_t(arrayElementCount)
            let elementsStartAddress = buffer.baseAddress!
                .advanced(by: MemoryLayout<mach_msg_type_number_t>.size)
            for (index, element) in arrayElements.enumerated() {
                let elementBuffer = UnsafeMutableRawBufferPointer(
                    start: elementsStartAddress.advanced(by: index * arrayElementSize),
                    count: arrayElementSize
                )
                elementBuffer.copyMemory(from: UnsafeRawBufferPointer(element.toRawBuffer()))
            }
            return UnsafeRawBufferPointer(buffer)
        }

    }

    /// A payload element representing a variable-length string.
    public struct VariableLengthCStringPayloadSegment: Mach.MessagePayloadSegment {
        /// The string itself.
        public var string: String

        /// Initializes a payload element with the given string.
        public init(_ string: String) {
            self.string = string
        }

        public func toRawBuffer() -> UnsafeRawBufferPointer {
            let cString = string.cString(using: .utf8)!

            let bufferSize =
                // The MIG-generated code includes an "offset" field that it doesn't actually use, but
                //  we need to replicate it here to match the expected buffer layout.
                MemoryLayout<mach_msg_type_number_t>.size
                // We'll allocate space for the actual size of the string with the null terminator.
                + MemoryLayout<mach_msg_type_number_t>.size
                + cString.count
            let buffer =
                UnsafeMutableRawBufferPointer.allocate(
                    byteCount: (bufferSize + 3) & ~3,
                    alignment: 4
                )

            // Zero out the buffer.
            buffer.baseAddress!.initializeMemory(as: UInt8.self, repeating: 0, count: buffer.count)

            // We set the "offset" field to 0. As it's not actually used, this should be fine.
            buffer.baseAddress!
                .assumingMemoryBound(to: mach_msg_type_number_t.self)
                .pointee = mach_msg_type_number_t(0)
            // We set the size of the string with the null terminator.
            buffer.baseAddress!
                .advanced(by: MemoryLayout<mach_msg_type_number_t>.size)
                .assumingMemoryBound(to: mach_msg_type_number_t.self)
                .pointee = mach_msg_type_number_t(cString.count)
            // We copy the string into the buffer.
            buffer.baseAddress!
                .advanced(by: MemoryLayout<mach_msg_type_number_t>.size * 2)
                .copyMemory(from: cString, byteCount: cString.count)
            return UnsafeRawBufferPointer(buffer)
        }
    }
}

extension Mach.TrivialMessagePayloadSegment {
    public func toRawBuffer() -> UnsafeRawBufferPointer {
        return withUnsafeBytes(of: self) { bytes in
            let newBuffer = UnsafeMutableRawBufferPointer.allocate(
                byteCount: MemoryLayout<Self>.size,
                alignment: MemoryLayout<Self>.alignment
            )
            newBuffer.copyMemory(from: bytes)
            return UnsafeRawBufferPointer(newBuffer)
        }
    }
}

/// A C character as a trivial message payload element.
extension CChar: Mach.TrivialMessagePayloadSegment {}

/// Data as a message payload segment.
extension Data: Mach.MessagePayloadSegment {
    /// Converts the data to a raw buffer.
    public func toRawBuffer() -> UnsafeRawBufferPointer {
        return withUnsafeBytes { bytes in
            let newBuffer = UnsafeMutableRawBufferPointer.allocate(
                byteCount: count,
                alignment: MemoryLayout<CChar>.alignment
            )
            newBuffer.copyMemory(from: bytes)
            return UnsafeRawBufferPointer(newBuffer)
        }
    }
}
