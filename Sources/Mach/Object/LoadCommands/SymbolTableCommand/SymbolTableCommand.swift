import Foundation
import KassHelpers
import MachCore
import MachO

extension symtab_command: Mach.CLoadCommand {}

extension Mach {
    /// A symbol table load command.
    public struct SymbolTableCommand: LoadCommand {
        public typealias CLoadCommandType = symtab_command
        public let data: Data
        public init(data: Data) { self.data = data }
    }
}

extension Mach.SymbolTableCommand {
    /// The offset to the symbol table.
    public var symbolOffset: UInt32 {
        data.withUnsafeBytes {
            $0.load(as: CLoadCommandType.self).symoff
        }
    }

    /// The number of symbols.
    public var numberOfSymbols: UInt32 {
        data.withUnsafeBytes {
            $0.load(as: CLoadCommandType.self).nsyms
        }
    }

    /// The offset to the string table.
    public var stringOffset: UInt32 {
        data.withUnsafeBytes {
            $0.load(as: CLoadCommandType.self).stroff
        }
    }

    /// The size of the string table.
    public var stringSize: UInt32 {
        data.withUnsafeBytes {
            $0.load(as: CLoadCommandType.self).strsize
        }
    }
}
