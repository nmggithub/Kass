import Darwin.POSIX
import Foundation

extension BSD {
    /// A parseable attribute.
    protocol FSParseableAttribute {
        /// Parses the attribute from a pointer and advances the pointer to the next attribute.
        func parse(from pointer: inout UnsafeRawPointer) -> Any

        /// Parses the data from the attribute reference.
        static func data(from attributeReference: UnsafePointer<attrreference>) -> Data
    }
}

extension BSD.FSParseableAttribute {
    public static func data(from attributeReference: UnsafePointer<attrreference>) -> Data {
        return Data(
            bytes: UnsafeRawPointer(attributeReference)
                .advanced(by: Int(attributeReference.pointee.attr_dataoffset)),
            count: Int(attributeReference.pointee.attr_length)
        )
    }
}

extension Array where Element: Hashable, Element: BSD.FSParseableAttribute {
    /// Maps the attributes to their parsed values.
    func map(fromPointer pointer: inout UnsafeRawPointer) -> [Element: Any] {
        var parsed: [Element: Any] = [:]
        for attribute in self {
            parsed[attribute] = attribute.parse(from: &pointer)
        }
        return parsed
    }
}

extension BSD {
    /// Parsed attributes from an attribute buffer.
    public struct FSParsedAttributes {
        public let common: [BSD.FSCommonAttributes: Any]
        public let volume: [BSD.FSVolumeAttributes: Any]
        public let directory: [BSD.FSDirectoryAttributes: Any]
        public let file: [BSD.FSFileAttributes: Any]
        public let commonExtended: [BSD.FSCommonExtendedAttributes: Any]
    }
}

extension BSD.FSAttributeBuffer {
    /// Parses the attribute buffer.
    public func parse() -> BSD.FSParsedAttributes {
        var pointer = self.bufferPointer.baseAddress!
            .advanced(by: MemoryLayout<UInt32>.size)  // Skip the length field.
            .advanced(by: MemoryLayout<attribute_set_t>.size)  // Skip the returned attributes field.

        // Attributes are grouped by type and parsed in a specific order that is documented in the `getattrlist`
        // manpage. We use `allCases`, so we must ensure our `allCases` arrays are in the proper order.

        // TODO: Confirm that the parameters of this initializer will always be evaluated in the same order.
        return .init(
            common: BSDCore.BSD.FSCommonAttributes.allCases
                .filter({ self.returnedAttributes.commonAttributes.contains($0) })
                .filter({ $0 != .returnedAttributes })  // We already parsed this
                .map(fromPointer: &pointer),

            volume: BSDCore.BSD.FSVolumeAttributes.allCases
                .filter({ self.returnedAttributes.volumeAttributes.contains($0) })
                .map(fromPointer: &pointer),

            directory: BSDCore.BSD.FSDirectoryAttributes.allCases
                .filter({ self.returnedAttributes.directoryAttributes.contains($0) })
                .map(fromPointer: &pointer),

            file: BSDCore.BSD.FSFileAttributes.allCases
                .filter({ self.returnedAttributes.fileAttributes.contains($0) })
                .map(fromPointer: &pointer),

            commonExtended: BSDCore.BSD.FSCommonExtendedAttributes.allCases
                .filter({ self.returnedAttributes.commonExtendedAttributes.contains($0) })
                .map(fromPointer: &pointer)
        )

    }
}

extension UnsafeRawPointer {
    /// Parses an attribute from the pointer and advances the pointer.
    /// - Parameters:
    ///   - type: The type of the value.
    /// - Returns: The parsed value.
    mutating func parseAttribute<T>(as type: T.Type) -> T {
        let value = self.load(as: type)
        self += MemoryLayout<T>.size
        return value
    }
}
