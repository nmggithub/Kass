import Darwin.POSIX
import Foundation

extension BSD.FS.Attribute {
    /// A parseable attribute.
    public protocol Parseable {
        /// Parses the attribute from a pointer and advances the pointer to the next attribute.
        /// - Parameter pointer: The pointer to the attribute.
        func parse(from pointer: inout UnsafeRawPointer) -> Any
        /// Parses the data from the attribute reference.
        /// - Parameter attributeReference: The attribute reference.
        /// - Returns: The data.
        static func data(from attributeReference: UnsafePointer<attrreference>) -> Data
    }
}

extension BSD.FS.Attribute.Parseable {
    public static func data(from attributeReference: UnsafePointer<attrreference>) -> Data {
        return Data(
            bytes: UnsafeRawPointer(attributeReference)
                .advanced(by: Int(attributeReference.pointee.attr_dataoffset)),
            count: Int(attributeReference.pointee.attr_length)
        )
    }
}

extension Array where Element: Hashable, Element: BSD.FS.Attribute.Parseable {
    /// Maps the attributes to their parsed values.
    /// - Parameter pointer: The pointer to the attribute data.
    /// - Returns: The parsed attributes.
    public func map(from pointer: inout UnsafeRawPointer) -> [Element: Any] {
        var parsed: [Element: Any] = [:]
        for attribute in self {
            parsed[attribute] = attribute.parse(from: &pointer)
        }
        return parsed
    }
}

extension BSD.FS.Attribute.Buffer {
    public struct ParsedAttributes {
        public let common: [BSD.FS.Attribute.Common: Any]
        public let volume: [BSD.FS.Attribute.Volume: Any]
        public let directory: [BSD.FS.Attribute.Directory: Any]
        public let file: [BSD.FS.Attribute.File: Any]
        public let commonExtended: [BSD.FS.Attribute.Common.Extended: Any]
    }
    public func parse() -> ParsedAttributes {
        var pointer = UnsafeRawPointer(data.withUnsafeBytes { $0.baseAddress! })
            .advanced(by: MemoryLayout<UInt32>.size)  // Skip the length field

        // Attributes are grouped by type and parsed in a specific order that is documented in the `getattrlist`
        // manpage. We use `allCases`, which returns the cases in declaration order, to ensure that we parse the
        // returned attributes in the correct order. Our attribute enums should be declared in the proper order.

        // TODO: Confirm that the parameters of this initializer will always be evaluated in the same order
        return .init(
            common: BSD.FS.Attribute.Common.allCases
                .filter({ self.returnedAttributes.common.contains($0) })
                .filter({ $0 != .returnedAttributes })  // We already parsed this
                .map(from: &pointer),
            volume: BSD.FS.Attribute.Volume.allCases
                .filter({ self.returnedAttributes.volume.contains($0) })
                .map(from: &pointer),
            directory: BSD.FS.Attribute.Directory.allCases
                .filter({ self.returnedAttributes.directory.contains($0) })
                .map(from: &pointer),
            file: BSD.FS.Attribute.File.allCases
                .filter({ self.returnedAttributes.file.contains($0) })
                .map(from: &pointer),
            commonExtended: BSD.FS.Attribute.Common.Extended.allCases
                .filter({ self.returnedAttributes.commonExtended.contains($0) })
                .map(from: &pointer)
        )

    }
}
