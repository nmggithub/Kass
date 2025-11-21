import Foundation
import MachO

extension Mach {
    /// A C representation of a Mach object header.
    public protocol CHeader: Sendable {
        /// The magic bytes of the header.
        var magic: UInt32 { get }

        /// The number of load commands in the Mach object.
        var ncmds: UInt32 { get }
    }

    /// A Mach object.
    public protocol Object<CHeaderType>: Sendable {
        /// The C representation of the object header.
        associatedtype CHeaderType: CHeader

        /// The object header.
        var header: CHeaderType { get }

        /// The object data.
        var data: Data { get }

        /// Initializes a Mach object from its raw data.
        init(data: Data)
    }
}

extension Mach {
    /// The magic field of a Mach object header.
    public struct HeaderMagic: RawRepresentable, CaseIterable, Equatable, Sendable {
        public let rawValue: UInt32

        /// The object is a 32-bit Mach object with native endianess.
        public static let native32Bit =
            HeaderMagic(magicValue: MH_MAGIC)

        /// The object is a 32-bit Mach object with swapped endianess.
        public static let swapped32Bit =
            HeaderMagic(magicValue: MH_CIGAM)

        /// The object is a 64-bit Mach object with native endianess.
        public static let native64Bit =
            HeaderMagic(magicValue: MH_MAGIC_64)

        /// The object is a 64-bit Mach object with swapped endianess.
        public static let swapped64Bit =
            HeaderMagic(magicValue: MH_CIGAM_64)

        /// All possible header magic values.
        public static let allCases: [HeaderMagic] = [
            .native32Bit,
            .swapped32Bit,
            .native64Bit,
            .swapped64Bit,
        ]

        /// Initializes header magic with a magic value.
        /// - Note: This is only to be used for defining static constants.
        private init(magicValue: UInt32) {
            self.rawValue = magicValue
        }

        /// Initializes header magic from its raw value.
        public init?(rawValue: UInt32) {
            if Self.allCases.contains(where: { $0.rawValue == rawValue }) {
                self.rawValue = rawValue
            } else {
                return nil
            }
        }
    }
}

extension Mach.Object {
    /// The header magic of the Mach object.
    public var headerMagic: Mach.HeaderMagic? {
        Mach.HeaderMagic(rawValue: self.header.magic)
    }

    /// Whether the Mach object has swapped endianess.
    public var hasSwappedEndianess: Bool {
        switch self.headerMagic {
        case .swapped32Bit, .swapped64Bit:
            return true
        default:
            return false
        }
    }
}

extension Mach {
    /// A 32-bit Mach object.
    public struct Object32: Mach.Object {
        public typealias CHeaderType = mach_header
        public let data: Data
        public init(data: Data) {
            self.data = data
            if self.hasSwappedEndianess {
                fatalError("Swapped endianess is not yet supported.")
            }
        }
    }

    /// A 64-bit Mach object.
    public struct Object64: Mach.Object {
        public typealias CHeaderType = mach_header_64
        public let data: Data
        public init(data: Data) {
            self.data = data
            if self.hasSwappedEndianess {
                fatalError("Swapped endianess is not yet supported.")
            }
        }
    }
}

extension Mach.Object {
    /// Initializes a Mach object from a header pointer and size.
    public init(headerPointer: UnsafeMutablePointer<CHeaderType>, size: Int) {
        self.init(
            data: Data(
                bytes: UnsafeRawPointer(headerPointer),
                count: size
            )
        )
    }
}

extension Mach.Object {
    public var header: CHeaderType {
        data.withUnsafeBytes { $0.load(as: CHeaderType.self) }
    }
}

extension mach_header: Mach.CHeader {}
extension mach_header_64: Mach.CHeader {}
