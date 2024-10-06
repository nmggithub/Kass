import Darwin.POSIX
import Foundation

extension UnsafeRawPointer {
    /// Parses an attribute reference from the pointer and advances the pointer.
    mutating func getAttributeReference() -> UnsafePointer<attrreference> {
        let reference = self.bindMemory(to: attrreference.self, capacity: 1)
        self += MemoryLayout<attrreference>.size
        return reference
    }
}

extension BSD {
    /// An attribute reference parser function.
    public typealias FSAttributeReferenceParserFunction<T> = (Data) -> T
    /// A parser for the attribute data.
    public struct FSAttributeReferenceParser<T> {
        /// The parser function.
        let parse: BSD.FSAttributeReferenceParserFunction<T>
        /// A parser for a null-terminated string attribute.
        public static var string: FSAttributeReferenceParser<String> {
            FSAttributeReferenceParser<String> { data in
                // The string is null-terminated, so we need to remove the last byte.
                String(decoding: data.subdata(in: 0..<(data.count - 1)), as: UTF8.self)
            }
        }
    }
}

extension UnsafePointer where Pointee == attrreference {
    /// The data of the attribute.
    var data: Data {
        Data(
            bytes: UnsafeRawPointer(self)
                .advanced(by: Int(self.pointee.attr_dataoffset)),
            count: Int(self.pointee.attr_length)
        )
    }

    /// Parses the attribute data.
    public func parse<ParsedType>(
        withParser parser: BSD.FSAttributeReferenceParser<ParsedType>
    ) -> ParsedType {
        parser.parse(self.data)
    }

    /// Parses the attribute data.
    public func parse<ParsedType>(
        withFunction parserFunction: @escaping BSD.FSAttributeReferenceParserFunction<ParsedType>
    ) -> ParsedType {
        BSD.FSAttributeReferenceParser(parse: parserFunction).parse(self.data)
    }
}
