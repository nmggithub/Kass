import Foundation
import MachO

extension Mach {
    /// A C representation of a load command.
    public protocol CLoadCommand: Sendable {
        /// The type of the load command.
        var cmd: UInt32 { get }

        /// The size of the load command.
        var cmdsize: UInt32 { get }
    }

    /// A load command in a Mach object.
    public protocol LoadCommand: Sendable {
        /// The C representation of the load command.
        associatedtype CLoadCommandType: CLoadCommand

        /// The type of the load command.
        var type: UInt32 { get }

        /// The size of the load command.
        var size: UInt32 { get }

        /// The raw data of the load command.
        var data: Data { get }

        /// Initializes a load command from its raw data.
        init(data: Data)

        /// Initializes a load command from a pointer to its C representation.
        init(commandPointer: UnsafeMutablePointer<CLoadCommandType>)
    }
}

extension Mach.LoadCommand {
    public init(commandPointer: UnsafeMutablePointer<CLoadCommandType>) {
        self.init(
            data: Data(
                bytes: UnsafeRawPointer(commandPointer),
                count: Int(MemoryLayout<CLoadCommandType>.size)
            )
        )
    }
}

extension Mach.LoadCommand {
    public var type: UInt32 { data.withUnsafeBytes { $0.load(as: CLoadCommandType.self).cmd } }
    public var size: UInt32 { data.withUnsafeBytes { $0.load(as: CLoadCommandType.self).cmdsize } }
    public var cLoadCommand: CLoadCommandType {
        data.withUnsafeBytes { $0.load(as: CLoadCommandType.self) }
    }
}

extension load_command: Mach.CLoadCommand {}

extension Mach {
    public struct UnknownLoadCommand: LoadCommand {
        public typealias CLoadCommandType = load_command
        public let data: Data
        public init(data: Data) { self.data = data }
    }
}

private let loadCommandTypeMap: [UInt32: any Mach.LoadCommand.Type] = [
    // Add known load command types here as needed.
    UInt32(LC_SEGMENT): Mach.Segment32Command.self,
    UInt32(LC_SEGMENT_64): Mach.Segment64Command.self,
]

extension Mach {
    /// An iterator over the load commands in a Mach object.
    fileprivate struct LoadCommandIterator<ObjectCHeaderType: Mach.CHeader>: IteratorProtocol {
        /// The element type.
        public typealias Element = any Mach.LoadCommand

        /// The count of the load commands.
        private let count: Int

        /// The current index.
        private var index: Int = 0

        /// The object being iterated over.
        private let object: any Mach.Object<ObjectCHeaderType>

        /// Initializes an iterator with a Mach object.
        init(object: any Mach.Object<ObjectCHeaderType>) {
            // Initialize the iterator with the object's load commands.
            self.object = object
            self.count = Int(object.header.ncmds)
        }

        /// The current offset in the object's data.
        private var offset: Int = MemoryLayout<ObjectCHeaderType>.size

        /// Deserializes a load command from a pointer.
        private static func deserialize<LoadCommandType: Mach.LoadCommand>(
            type: LoadCommandType.Type,
            fromPointer commandPointer: UnsafeMutablePointer<load_command>,
            withObject object: any Mach.Object
        ) -> LoadCommandType {
            commandPointer.withMemoryRebound(to: type.CLoadCommandType, capacity: 1) {
                LoadCommandType.init(commandPointer: $0)
            }
        }

        /// Advances to the next load command and returns it, or `nil` if there are no more load commands.
        public mutating func next() -> Element? {
            guard self.index < self.count else { return nil }

            // Create a pointer to the current load command.
            let commandPointer = UnsafeMutableRawPointer(
                mutating: (self.object.data as NSData).bytes
            ).advanced(by: offset)
                .bindMemory(to: load_command.self, capacity: 1)

            // Determine the load command type.
            let loadCommandType =
                loadCommandTypeMap[commandPointer.pointee.cmd]
                ?? Mach.UnknownLoadCommand.self

            // Deserialize the load command.
            let loadCommand =
                Self.deserialize(
                    type: loadCommandType,
                    fromPointer: commandPointer,
                    withObject: object
                )

            // Advance the offset and index.
            offset += Int(loadCommand.size)
            index += 1

            return loadCommand
        }
    }
}

extension Mach.Object {
    /// The load commands contained in the Mach object.
    public var loadCommands: [any Mach.LoadCommand] {
        var commands: [any Mach.LoadCommand] = []
        var iterator = Mach.LoadCommandIterator(object: self)
        while let command = iterator.next() {
            commands.append(command)
        }
        return commands
    }
}
