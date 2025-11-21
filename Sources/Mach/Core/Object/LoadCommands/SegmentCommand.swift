import Foundation
import MachO

// MARK: - C Segment Command

extension Mach {
    public protocol CSegmentCommand<PointerType>: Mach.CLoadCommand {
        associatedtype PointerType: UnsignedInteger
        var segname: Mach.CNameString { get }
        var vmaddr: PointerType { get }
        var vmsize: PointerType { get }
        var fileoff: PointerType { get }
        var filesize: PointerType { get }
        var maxprot: Int32 { get }
        var initprot: Int32 { get }
        var nsects: UInt32 { get }
        var flags: UInt32 { get }
    }
}

extension segment_command: Mach.CSegmentCommand {}
extension segment_command_64: Mach.CSegmentCommand {}

// MARK: - Segment Command

extension Mach {
    /// A segment load command.
    public protocol SegmentCommand: Mach.LoadCommand where CLoadCommandType: CSegmentCommand {
        /// The name of the segment.
        var name: String { get }

        /// The VM buffer of the segment.
        var vmBuffer: UnsafeRawBufferPointer { get }

        /// The file offset of the segment.
        var fileOffset: CLoadCommandType.PointerType { get }

        /// The file size of the segment.
        var fileSize: CLoadCommandType.PointerType { get }

        /// The maximum VM protection of the segment.
        var maxProtection: Mach.VMProtectionOptions { get }

        /// The initial VM protection of the segment.
        var initProtection: Mach.VMProtectionOptions { get }

        /// The number of sections in the segment.
        var numberOfSections: UInt32 { get }

        /// The flags of the segment.
        var flags: UInt32 { get }
    }
}

extension Mach.SegmentCommand {
    public var name: String {
        data.withUnsafeBytes { pointer in
            let cmd = pointer.load(as: CLoadCommandType.self)
            return cNameStringToString(cmd.segname)
        }
    }

    public var vmBuffer: UnsafeRawBufferPointer {
        let vmaddr =
            data.withUnsafeBytes {
                $0.load(as: CLoadCommandType.self).vmaddr
            }
        let vmsize =
            data.withUnsafeBytes {
                $0.load(as: CLoadCommandType.self).vmsize
            }
        return UnsafeRawBufferPointer(
            start: UnsafeRawPointer(bitPattern: UInt(vmaddr)),
            count: Int(vmsize)
        )
    }

    public var fileOffset: CLoadCommandType.PointerType {
        data.withUnsafeBytes {
            $0.load(as: CLoadCommandType.self).fileoff
        }
    }

    public var fileSize: CLoadCommandType.PointerType {
        data.withUnsafeBytes {
            $0.load(as: CLoadCommandType.self).filesize
        }
    }

    public var maxProtection: Mach.VMProtectionOptions {
        Mach.VMProtectionOptions(
            rawValue: data.withUnsafeBytes {
                $0.load(as: CLoadCommandType.self).maxprot
            }
        )
    }

    public var initProtection: Mach.VMProtectionOptions {
        Mach.VMProtectionOptions(
            rawValue: data.withUnsafeBytes {
                $0.load(as: CLoadCommandType.self).initprot
            }
        )
    }

    public var numberOfSections: UInt32 {
        data.withUnsafeBytes {
            $0.load(as: CLoadCommandType.self).nsects
        }
    }

    public var flags: UInt32 {
        data.withUnsafeBytes {
            $0.load(as: CLoadCommandType.self).flags
        }
    }
}

extension Mach {
    /// A 32-bit segment load command.
    public struct Segment32Command: SegmentCommand {
        public typealias CLoadCommandType = segment_command
        public let data: Data
        public init(data: Data) { self.data = data }
    }

    /// A 64-bit segment load command.
    public struct Segment64Command: SegmentCommand {
        public typealias CLoadCommandType = segment_command_64
        public let data: Data
        public init(data: Data) { self.data = data }
    }
}

// MARK: - Section

extension Mach {
    /// A section in a segment.
    public protocol Section<PointerType>: Sendable {
        associatedtype PointerType: UnsignedInteger
        var sectname: Mach.CNameString { get }
        var segname: Mach.CNameString { get }
        var addr: PointerType { get }
        var size: PointerType { get }
        var offset: UInt32 { get }
        var align: UInt32 { get }
        var reloff: UInt32 { get }
        var nreloc: UInt32 { get }
        var flags: UInt32 { get }
        var reserved1: UInt32 { get }
        var reserved2: UInt32 { get }
    }
}

extension section: Mach.Section {}
extension section_64: Mach.Section {}

extension Mach.Section {
    public var name: String { return cNameStringToString(self.sectname) }
    public var segmentName: String { return cNameStringToString(self.segname) }

    public var vmBuffer: UnsafeRawBufferPointer {
        return UnsafeRawBufferPointer(
            start: UnsafeRawPointer(bitPattern: UInt(self.addr)),
            count: Int(self.size)
        )
    }

    public var fileOffset: UInt32 { self.offset }

    public var alignment: UInt32 { self.align }

    public var relocationOffset: UInt32 { self.reloff }
    public var numberOfRelocations: UInt32 { self.nreloc }
}

extension Mach.SegmentCommand {
    /// The sections in the segment.
    public var sections: [any Mach.Section] {
        let sectionType: any Mach.Section.Type =
            self is Mach.Segment32Command
            ? section.self
            : section_64.self
        var sections: [any Mach.Section] = []
        var currentOffset = MemoryLayout<CLoadCommandType>.size
        for _ in 0..<numberOfSections {
            let sectionData = data.subdata(
                in: currentOffset..<(currentOffset + MemoryLayout<section>.size)
            )
            let section = sectionData.withUnsafeBytes {
                $0.load(as: sectionType)
            }
            sections.append(section)
            currentOffset += MemoryLayout<section>.size
        }
        return sections
    }
}

// MARK: - File Data Helpers

extension Mach.SegmentCommand {
    /// Gets the file data for this segment from a Mach object.
    public func fileData(withObject object: any Mach.Object) -> Data {
        return object.data.subdata(
            in: Int(fileOffset)..<Int(fileOffset + fileSize)
        )
    }
}

extension Mach.Section {
    /// Gets the file data for this section from a Mach object.
    public func fileData(withObject object: any Mach.Object) -> Data {
        return object.data.subdata(
            in: Int(fileOffset)..<Int(PointerType(fileOffset) + size)
        )
    }
}
