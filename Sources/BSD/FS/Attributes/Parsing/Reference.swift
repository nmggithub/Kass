import Darwin.POSIX
import Foundation

extension BSD.FS.Attribute {
    /// A reference to an attribute.
    public struct Reference {
        /// The data of the attribute.
        public let data: Data
        /// Creates a new attribute reference.
        ///   - pointer: A pointer to the attribute reference.
        init(_ pointer: UnsafeRawPointer) {
            let attributeReference = pointer.load(as: attrreference.self)
            self.data = Data(
                bytes: pointer.advanced(by: Int(attributeReference.attr_dataoffset)),
                count: Int(attributeReference.attr_length)
            )
        }
    }
}

extension UnsafeRawPointer {
    /// Parses an attribute reference from the pointer and advances the pointer.
    /// - Returns: The attribute data.
    mutating func getAttributeReference() -> BSD.FS.Attribute.Reference {
        let reference = BSD.FS.Attribute.Reference(self)
        self += MemoryLayout<attrreference>.size
        return reference
    }
}

extension BSD.FS.Attribute.Reference {
    /// A parser for the attribute data.
    public struct Parser<T> {
        /// A parser function.
        public typealias Function = (Data) -> T
        /// The parser function.
        let parse: Function
        /// A parser for a null-terminated string attribute.
        public static var string: Parser<String> {
            Parser<String> { data in
                // The string is null-terminated, so we need to remove the last byte.
                String(decoding: data.subdata(in: 0..<(data.count - 1)), as: UTF8.self)
            }
        }
    }

    /// Parses the attribute data.
    /// - Parameter parser: The parser to use.
    /// - Returns: The parsed data.
    public func parse<T>(with parser: Parser<T>) -> T {
        parser.parse(self.data)
    }

    /// Parses the attribute data.
    /// - Parameter parserFunction: The parser function to use.
    /// - Returns: The parsed data.
    public func parse<T>(with parserFunction: @escaping Parser<T>.Function) -> T {
        Parser<T>(parse: parserFunction).parse(self.data)
    }
}
