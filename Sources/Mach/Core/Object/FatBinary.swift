import Foundation
import KassHelpers

extension Mach {
    /// A fat Mach binary.
    public protocol FatBinary {
        /// A C representation of the fat binary architectures.
        associatedtype CFatArchitectureType: Mach.CFatArchitecture

        /// The fat binary header.
        var header: fat_header { get }

        /// The raw data of the fat binary.
        var data: Data { get }

        /// Initializes a fat binary from its raw data.
        init(data: Data)
    }
}

extension Mach.FatBinary {
    /// The fat binary header.
    public var header: fat_header {
        data.withUnsafeBytes {
            $0.load(as: fat_header.self)
        }
    }
}

extension Mach.FatBinary {
    /// Initializes a fat binary from a header pointer and size.
    public init(headerPointer: UnsafeMutablePointer<fat_header>, size: Int) {
        self.init(
            data: Data(
                bytes: UnsafeRawPointer(headerPointer),
                count: size
            )
        )
    }
}

extension Mach {
    /// A 32-bit fat Mach binary.
    public struct FatBinary32: Mach.FatBinary {
        public typealias CFatArchitectureType = fat_arch
        public let data: Data
        public init(data: Data) { self.data = data }
    }

    /// A 64-bit fat Mach binary.
    public struct FatBinary64: Mach.FatBinary {
        public typealias CFatArchitectureType = fat_arch_64
        public let data: Data
        public init(data: Data) { self.data = data }
    }
}

extension Mach {
    /// The magic field of the fat binary.
    public struct FatMagic: KassHelpers.NamedOptionEnum, Hashable, Sendable {
        /// The name of the magic, if it can be determined.
        public var name: String?

        /// Represents fat magic with an optional name.
        public init(name: String?, rawValue: UInt32) {
            guard Self.allCases.contains(where: { $0.rawValue == rawValue }) else {
                Mach.FatMagic.unsupported(fatMagic: rawValue)
            }
            self.name = name
            self.rawValue = rawValue
        }

        /// Initializes fat magic with a magic value.
        /// - Note: This is only to be used for defining static constants.
        private init(name: String, magicValue: UInt32) {
            self.name = name
            self.rawValue = magicValue
        }

        /// The raw magic value.
        public let rawValue: UInt32

        /// The architecture structure is a 32-bit structure with native endianess.
        public static let native32Bit =
            FatMagic(name: "native32Bit", magicValue: FAT_MAGIC)

        /// The architecture structure is a 32-bit structure with swapped endianess.
        public static let swapped32Bit =
            FatMagic(name: "swapped32Bit", magicValue: FAT_CIGAM)
        /// The architecture structure is a 64-bit structure with native endianess.
        public static let native64Bit =
            FatMagic(name: "native64Bit", magicValue: FAT_MAGIC_64)

        /// The architecture structure is a 64-bit structure with swapped endianess.
        public static let swapped64Bit =
            FatMagic(name: "swapped64Bit", magicValue: FAT_CIGAM_64)
        /// All possible header magic values.
        public static let allCases: [FatMagic] = [
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

        /// Raises a fatal error for unsupported fat binary magic values.
        public static func unsupported(fatMagic: UInt32) -> Never {
            fatalError(
                "Unsupported fat binary magic: "
                    + String(format: "0x%X", fatMagic)
            )
        }
    }
}

extension Mach.FatBinary {
    /// The magic of the fat binary.
    public var magic: Mach.FatMagic? {
        Mach.FatMagic(rawValue: self.header.magic)
    }

    /// Whether the fat binary has swapped endianess.
    public var hasSwappedEndianess: Bool {
        switch self.magic {
        case .swapped32Bit, .swapped64Bit:
            return true
        case .native32Bit, .native64Bit:
            return false
        default:
            Mach.FatMagic.unsupported(
                fatMagic: self.header.magic
            )
        }
    }
}

extension Mach.FatBinary {
    public var numberOfArchitectures: UInt32 {
        return self.hasSwappedEndianess
            ? self.header.nfat_arch.byteSwapped
            : self.header.nfat_arch
    }
}

extension Mach {
    /// An architecture in a fat binary.
    public protocol CFatArchitecture: Sendable {
        associatedtype PointerType: FixedWidthInteger
        var cputype: cpu_type_t { get }
        var cpusubtype: cpu_subtype_t { get }
        var offset: PointerType { get }
        var size: PointerType { get }
        var align: UInt32 { get }
    }
}

extension fat_arch: Mach.CFatArchitecture {}
extension fat_arch_64: Mach.CFatArchitecture {}

extension Mach {
    public struct FatArchitecture {

        /// The CPU type of the architecture.
        let cpuType: cpu_type_t

        /// The CPU subtype of the architecture.
        let cpuSubtype: cpu_subtype_t

        /// The offset of the architecture's object in the fat binary.
        let offset: any FixedWidthInteger

        /// The size of the architecture's object in the fat binary.
        let size: any FixedWidthInteger

        /// The alignment of the architecture's object in the fat binary.
        let alignment: UInt32

        /// The C representation of the architecture.
        let cRepresentation: any Mach.CFatArchitecture

        /// Initializes a fat architecture from its C representation.
        fileprivate init(cRepresentation: any Mach.CFatArchitecture, byteSwapped: Bool) {
            self.cRepresentation = cRepresentation
            if byteSwapped {
                self.cpuType = cRepresentation.cputype.byteSwapped
                self.cpuSubtype = cRepresentation.cpusubtype.byteSwapped
                self.offset = cRepresentation.offset.byteSwapped
                self.size = cRepresentation.size.byteSwapped
                self.alignment = cRepresentation.align.byteSwapped
            } else {
                self.cpuType = cRepresentation.cputype
                self.cpuSubtype = cRepresentation.cpusubtype
                self.offset = cRepresentation.offset
                self.size = cRepresentation.size
                self.alignment = cRepresentation.align
            }
        }
    }
}

extension Mach.FatArchitecture {
    public func object(withFatBinary fatBinary: some Mach.FatBinary) -> any Mach.Object {
        let objectData = fatBinary.data.subdata(
            in: Int(self.offset)..<Int(Int(self.offset) + Int(self.size))
        )
        let machMagic = objectData.withUnsafeBytes {
            $0.load(as: Mach.HeaderMagic.RawValue.self)
        }
        return switch Mach.HeaderMagic(rawValue: machMagic) {
        case .native32Bit, .swapped32Bit: Mach.Object32(data: objectData)
        case .native64Bit, .swapped64Bit: Mach.Object64(data: objectData)
        default: Mach.HeaderMagic.unsupported(machMagic: machMagic)
        }
    }
}

extension Mach.FatBinary {
    /// The architectures in the fat binary.
    public var architectures: [Mach.FatArchitecture] {
        data.withUnsafeBytes { bufferPointer in
            return Array(
                UnsafeBufferPointer(
                    start: UnsafeRawPointer(bufferPointer.baseAddress!)
                        .advanced(by: MemoryLayout<fat_header>.size)
                        .assumingMemoryBound(to: Self.CFatArchitectureType.self),
                    count: Int(self.numberOfArchitectures))
            )
        }.map {
            Mach.FatArchitecture(
                cRepresentation: $0,
                byteSwapped: self.hasSwappedEndianess
            )
        }
    }
}

extension Mach.FatBinary {
    /// The objects in the fat binary.
    public var objects: [any Mach.Object] {
        return architectures.map { $0.object(withFatBinary: self) }
    }
}

extension Mach {
    public static func fatBinary(fromData data: Data) -> any Mach.FatBinary {
        let fatMagic = data.withUnsafeBytes {
            $0.load(as: UInt32.self)
        }
        let headerMagic = Mach.FatMagic(rawValue: fatMagic)
        switch headerMagic {
        case .native32Bit, .swapped32Bit:
            return Mach.FatBinary32(data: data)
        case .native64Bit, .swapped64Bit:
            return Mach.FatBinary64(data: data)
        default:
            Mach.FatMagic.unsupported(fatMagic: fatMagic)
        }
    }
}
