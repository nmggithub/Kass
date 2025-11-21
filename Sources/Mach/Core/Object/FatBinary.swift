import Foundation

extension Mach {
    /// A fat Mach binary.
    public struct FatBinary {
        /// The fat header of the binary.
        public var header: fat_header {
            data.withUnsafeBytes { $0.load(as: fat_header.self) }
        }
        /// The data of the fat binary.
        public let data: Data

        /// Initializes a fat binary from its raw data.
        public init(data: Data) {
            self.data = data
            if self.hasSwappedEndianess {
                fatalError("Swapped endianess is not yet supported.")
            }
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

extension Mach.FatBinary {
    /// The magic field of the fat binary.
    public struct HeaderMagic: RawRepresentable, CaseIterable, Equatable, Sendable {
        public let rawValue: UInt32

        /// The architecture structure is a 32-bit structure with native endianess.
        public static let native32Bit =
            HeaderMagic(magicValue: FAT_MAGIC)

        /// The architecture structure is a 32-bit structure with swapped endianess.
        public static let swapped32Bit =
            HeaderMagic(magicValue: FAT_CIGAM)
        /// The architecture structure is a 64-bit structure with native endianess.
        public static let native64Bit =
            HeaderMagic(magicValue: FAT_MAGIC_64)

        /// The architecture structure is a 64-bit structure with swapped endianess.
        public static let swapped64Bit =
            HeaderMagic(magicValue: FAT_CIGAM_64)

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

extension Mach.FatBinary {
    /// The header magic of the fat binary.
    public var headerMagic: Mach.FatBinary.HeaderMagic? {
        Mach.FatBinary.HeaderMagic(rawValue: self.header.magic)
    }

    /// Whether the fat binary has swapped endianess.
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
    /// An architecture in a fat binary.
    public protocol FatArchitecture {
        associatedtype PointerType: UnsignedInteger
        var cputype: cpu_type_t { get }
        var cpusubtype: cpu_subtype_t { get }
        var offset: PointerType { get }
        var size: PointerType { get }
        var align: UInt32 { get }
    }
}

extension fat_arch: Mach.FatArchitecture {}
extension fat_arch_64: Mach.FatArchitecture {}

extension Mach.FatArchitecture {
    public func object(withFatBinary fatBinary: Mach.FatBinary) -> any Mach.Object {
        let objectData = fatBinary.data.subdata(
            in: Int(self.offset)..<Int(self.offset + PointerType(self.size))
        )
        let machMagic = objectData.withUnsafeBytes {
            $0.load(as: Mach.HeaderMagic.RawValue.self)
        }
        return switch Mach.HeaderMagic(rawValue: machMagic) {
        case .native32Bit, .swapped32Bit: Mach.Object32(data: objectData)
        case .native64Bit, .swapped64Bit: Mach.Object64(data: objectData)
        default:
            fatalError(
                "Unsupported Mach object magic: " + String(format: "0x%X", machMagic)
            )
        }
    }
}

extension Mach.FatBinary {
    /// The architectures in the fat binary.
    public var architectures: [any Mach.FatArchitecture] {
        let architectureType: any Mach.FatArchitecture.Type =
            switch self.headerMagic {
            case .native32Bit, .swapped32Bit: fat_arch.self
            case .native64Bit, .swapped64Bit: fat_arch_64.self
            default:
                fatalError(
                    "Unsupported fat binary magic: "
                        + String(format: "0x%X", self.header.magic)
                )
            }
        var architectures: [any Mach.FatArchitecture] = []
        let archSize = MemoryLayout<fat_arch>.size
        for index in 0..<Int(self.header.nfat_arch) {
            let offset = MemoryLayout<fat_header>.size + (index * archSize)
            let archData = data.subdata(in: offset..<(offset + archSize))
            let architecture =
                archData.withUnsafeBytes { $0.load(as: architectureType) }
            architectures.append(architecture)
        }
        return architectures
    }
}

extension Mach.FatBinary {
    /// The objects in the fat binary.
    public var objects: [any Mach.Object] {
        return architectures.map { $0.object(withFatBinary: self) }
    }
}
