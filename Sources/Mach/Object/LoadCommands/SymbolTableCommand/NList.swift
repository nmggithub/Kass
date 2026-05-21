import KassHelpers
import MachCore
import MachO

extension Mach.SymbolTableCommand {
    /// A C representation of a symbol table entry.
    public protocol CNlist<PointerType>: Sendable {
        associatedtype PointerType: FixedWidthInteger
        associatedtype DescFieldType: FixedWidthInteger
        var n_type: UInt8 { get }
        var n_sect: UInt8 { get }
        var n_desc: DescFieldType { get }
        var n_value: PointerType { get }
        // HACK: I can't get embedded structs/unions to work with extensions,
        //  so I'm pulling this property up to the main structure.
        var n_strx: UInt32 { get }
    }
}

extension nlist: Mach.SymbolTableCommand.CNlist {
    public var n_strx: UInt32 { self.n_un.n_strx }
}
extension nlist_64: Mach.SymbolTableCommand.CNlist {
    public var n_strx: UInt32 { self.n_un.n_strx }
}

extension Mach.SymbolTableCommand {
    /// A symbol table entry.
    public protocol NList: Sendable {
        /// The C representation of the symbol table entry.
        var cRepresentation: any CNlist { get }
    }
}

extension Mach.SymbolTableCommand {
    /// A normal symbol table entry.
    public struct SymbolTableEntry: NList {
        public let cRepresentation: any CNlist

        /// Initializes a normal symbol table entry from its C representation.
        public init?(cRepresentation: any CNlist) {
            guard (cRepresentation.n_type & UInt8(N_STAB)) == 0
            else { return nil }  // Normal symbol table entries should not have N_STAB set.
            self.cRepresentation = cRepresentation
        }
    }

    /// A symbolic debugging entry.
    public struct SymbolicDebuggingEntry: NList {
        public let cRepresentation: any CNlist

        /// Initializes a symbolic debugging entry from its C representation.
        public init?(cRepresentation: any CNlist) {
            guard (cRepresentation.n_type & UInt8(N_STAB)) != 0
            else { return nil }  // Symbolic debugging entries should have N_STAB set.
            self.cRepresentation = cRepresentation
        }
    }

    /// An unknown symbol table entry.
    /// - Note: This should never appear in normal usage, but exists as a fallback.
    public struct UnknownNList: NList {
        public let cRepresentation: any CNlist

        /// Initializes an unknown symbol table entry from its C representation.
        public init(cRepresentation: any CNlist) {
            self.cRepresentation = cRepresentation
        }
    }
}

extension Mach.SymbolTableCommand.NList {
    /// Initializes a symbol table entry from its C representation.
    public static func newEntry(
        fromCRepresentation cRepresentation:
            any Mach.SymbolTableCommand.CNlist
    ) -> Mach.SymbolTableCommand.NList {
        if let normalEntry =
            Mach.SymbolTableCommand.SymbolTableEntry(cRepresentation: cRepresentation)
        {
            normalEntry
        } else if let debugEntry =
            Mach.SymbolTableCommand.SymbolicDebuggingEntry(cRepresentation: cRepresentation)
        {
            debugEntry
        } else {
            Mach.SymbolTableCommand.UnknownNList(cRepresentation: cRepresentation)
        }
    }
}

extension Mach.SymbolTableCommand.NList {
    /// The string table index of the symbol.
    public var stringIndex: UInt32 {
        cRepresentation.n_strx
    }

    /// The type of the symbol.
    public var type: UInt8 {
        cRepresentation.n_type
    }

    /// The section number of the symbol.
    public var section: UInt8 {
        cRepresentation.n_sect
    }

    /// The description field of the symbol.
    public var description: any FixedWidthInteger {
        cRepresentation.n_desc
    }

    /// The value of the symbol.
    public var value: any FixedWidthInteger {
        cRepresentation.n_value
    }
}

extension Mach.SymbolTableCommand.SymbolTableEntry {
    /// A type of a symbol.
    public struct SymbolType: KassHelpers.NamedOptionEnum {
        /// The name of the type, if it can be determined.
        public var name: String?

        /// Represents a symbol type with an optional name.
        public init(name: String?, rawValue: UInt8) {
            self.name = name
            self.rawValue = rawValue
        }

        /// The raw value of the type.
        public let rawValue: UInt8

        /// All known symbol types.
        public static let allCases: [Self] = [
            .undefined,
            .absolute,
            .section,
            .preboundUndefined,
            .indirect,
        ]

        public static let undefined =
            SymbolType(name: "undefined", rawValue: UInt8(N_UNDF))

        public static let absolute =
            SymbolType(name: "absolute", rawValue: UInt8(N_ABS))

        public static let section =
            SymbolType(name: "section", rawValue: UInt8(N_SECT))

        public static let preboundUndefined =
            SymbolType(name: "preboundUndefined", rawValue: UInt8(N_PBUD))

        public static let `indirect` =
            SymbolType(name: "indirect", rawValue: UInt8(N_INDR))
    }
    /// The string table index of the symbol.
    public var stringIndex: UInt32 {
        cRepresentation.n_strx
    }

    /// The type of the symbol.
    public var symbolType: SymbolType {
        SymbolType(rawValue: cRepresentation.n_type & UInt8(N_TYPE))
    }

    /// Whether the symbol is a private external symbol.
    public var isPrivateExternal: Bool {
        (cRepresentation.n_type & UInt8(N_PEXT)) != 0
    }

    /// Whether the symbol is an external symbol.
    public var isExternal: Bool {
        (cRepresentation.n_type & UInt8(N_EXT)) != 0
    }
}

extension Mach.SymbolTableCommand.SymbolicDebuggingEntry {
    /// The symbolic debugging entry type.
    public struct SymbolicDebuggingEntryType: KassHelpers.NamedOptionEnum {
        /// The name of the type, if it can be determined.
        public var name: String?

        /// Represents a symbolic debugging entry type with an optional name.
        public init(name: String?, rawValue: UInt8) {
            self.name = name
            self.rawValue = rawValue
        }

        /// The raw value of the type.
        public let rawValue: UInt8

        /// All known symbolic debugging entry types.
        public static let allCases: [Self] = [
            .globalSymbol,
            .procedureName,
            .procedure,
            .staticSymbol,
            .lcommSymbol,
            .beginNsectSymbol,
            .astFilePath,
            .opt,
            .registedSymbol,
            .sourceLine,
            .endNsectSymbol,
            .structureElt,
            .sourceFileName,
            .objectFileName,
            .dynamicLibraryFileName,
            .localSymbol,
            .includeFileBegining,
            .includedFileName,
            .compilerParameters,
            .compilerVersion,
            .compilerOptimizationLevel,
            .parameter,
            .includeFileEnd,
            .alternateEntry,
            .leftBracket,
            .deletedIncludeFile,
            .rightBracket,
            .beginCommon,
            .endCommon,
            .endCommonLocalName,
            .length,
        ]

        public static let globalSymbol =
            SymbolicDebuggingEntryType(name: "globalSymbol", rawValue: UInt8(N_GSYM))

        public static let procedureName =
            SymbolicDebuggingEntryType(name: "procedureName", rawValue: UInt8(N_FNAME))

        public static let procedure =
            SymbolicDebuggingEntryType(name: "procedure", rawValue: UInt8(N_FUN))

        public static let staticSymbol =
            SymbolicDebuggingEntryType(name: "staticSymbol", rawValue: UInt8(N_STSYM))

        public static let lcommSymbol =
            SymbolicDebuggingEntryType(name: "lcommSymbol", rawValue: UInt8(N_LCSYM))

        public static let beginNsectSymbol =
            SymbolicDebuggingEntryType(name: "beginNsectSymbol", rawValue: UInt8(N_BNSYM))

        public static let astFilePath =
            SymbolicDebuggingEntryType(name: "astFilePath", rawValue: UInt8(N_AST))

        public static let opt =
            SymbolicDebuggingEntryType(name: "opt", rawValue: UInt8(N_OPT))

        public static let registedSymbol =
            SymbolicDebuggingEntryType(name: "registedSymbol", rawValue: UInt8(N_RSYM))

        public static let sourceLine =
            SymbolicDebuggingEntryType(name: "sourceLine", rawValue: UInt8(N_SLINE))

        public static let endNsectSymbol =
            SymbolicDebuggingEntryType(name: "endNsectSymbol", rawValue: UInt8(N_ENSYM))

        public static let structureElt =
            SymbolicDebuggingEntryType(name: "structureElt", rawValue: UInt8(N_SSYM))

        public static let sourceFileName =
            SymbolicDebuggingEntryType(name: "sourceFileName", rawValue: UInt8(N_SO))

        public static let objectFileName =
            SymbolicDebuggingEntryType(name: "objectFileName", rawValue: UInt8(N_OSO))

        public static let dynamicLibraryFileName =
            SymbolicDebuggingEntryType(name: "dynamicLibraryFileName", rawValue: UInt8(N_LIB))

        public static let localSymbol =
            SymbolicDebuggingEntryType(name: "localSymbol", rawValue: UInt8(N_LSYM))

        public static let includeFileBegining =
            SymbolicDebuggingEntryType(name: "includeFileBeginning", rawValue: UInt8(N_BINCL))

        public static let includedFileName =
            SymbolicDebuggingEntryType(name: "includedFileName", rawValue: UInt8(N_SOL))

        public static let compilerParameters =
            SymbolicDebuggingEntryType(name: "compilerParameters", rawValue: UInt8(N_PSYM))

        public static let compilerVersion =
            SymbolicDebuggingEntryType(name: "compilerVersion", rawValue: UInt8(N_VERSION))

        public static let compilerOptimizationLevel =
            SymbolicDebuggingEntryType(name: "compilerOptimizationLevel", rawValue: UInt8(N_OLEVEL))

        public static let parameter =
            SymbolicDebuggingEntryType(name: "parameter", rawValue: UInt8(N_PSYM))

        public static let includeFileEnd =
            SymbolicDebuggingEntryType(name: "includeFileEnd", rawValue: UInt8(N_EINCL))

        public static let alternateEntry =
            SymbolicDebuggingEntryType(name: "alternateEntry", rawValue: UInt8(N_ENTRY))

        public static let leftBracket =
            SymbolicDebuggingEntryType(name: "leftBracket", rawValue: UInt8(N_LBRAC))

        public static let deletedIncludeFile =
            SymbolicDebuggingEntryType(name: "deletedIncludeFile", rawValue: UInt8(N_EXCL))

        public static let rightBracket =
            SymbolicDebuggingEntryType(name: "rightBracket", rawValue: UInt8(N_RBRAC))

        public static let beginCommon =
            SymbolicDebuggingEntryType(name: "beginCommon", rawValue: UInt8(N_BCOMM))

        public static let endCommon =
            SymbolicDebuggingEntryType(name: "endCommon", rawValue: UInt8(N_ECOMM))

        public static let endCommonLocalName =
            SymbolicDebuggingEntryType(name: "endCommonLocalName", rawValue: UInt8(N_ECOML))

        public static let length =
            SymbolicDebuggingEntryType(name: "length", rawValue: UInt8(N_LENG))
    }

    /// The symbolic debugging entry type.
    public var symbolicDebuggingEntryType: SymbolicDebuggingEntryType {
        SymbolicDebuggingEntryType(rawValue: cRepresentation.n_type)
    }
}
