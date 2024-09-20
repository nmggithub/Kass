/// A protocol that represents any value that can be represented by a C macro.
public protocol NameableByCMacro {
    /// The name of the C macro that represents the value.
    var cMacroName: String { get }
}

/// A protocol that represents any value that can be represented by multiple C macro (i.e. an option set).
public protocol NameableByCMacros {
    /// The names of the C macros that represent the value.
    var cMacroNames: Set<String> { get }
}

/// A protocol that represents any binary integer value that can be represented by a C macro.
/// - Note: This protocol is meant to be used with raw-value enums that represent C macros.
public protocol CBinIntMacroEnum: NameableByCMacro, RawRepresentable
where RawValue: BinaryInteger {}

/// A protocol for a C option macro enum.
public protocol COptionMacroEnum: CBinIntMacroEnum, Hashable, CaseIterable {}

/// A struct that represents a set of options defined by C option macros.
public struct COptionMacroSet<CMacroEnum: COptionMacroEnum>: NameableByCMacros,
    ExpressibleByArrayLiteral, RawRepresentable
{
    /// The raw value of the set of options, as a binary integer.
    public var rawValue: CMacroEnum.RawValue { options.bitmap() }
    /// Creates a new set of options from a raw value.
    /// - Parameter rawValue: The raw value.
    public init?(rawValue: CMacroEnum.RawValue) {
        self.options = Set(CMacroEnum.allCases.filter { rawValue & $0.rawValue != 0 })
    }
    /// The set of options.
    private var options: Set<CMacroEnum> = []
    /// The set of C macro names that represent the options.
    public var cMacroNames: Set<String> { Set(options.map { $0.cMacroName }) }
    /// Creates a new set of options from an array of options.
    /// - Parameter optionsIn: The options.
    public init(arrayLiteral optionsIn: CMacroEnum...) {
        self.options = Set(optionsIn)
    }
    /// Sets one or more options.
    /// - Parameter optionsToSet: The options to set.
    public mutating func set(_ optionsToSet: CMacroEnum...) {
        self.options.formUnion(optionsToSet)
    }
    /// Unsets one or more options.
    /// - Parameter optionsToUnset: The options to unset.
    public mutating func unset(_ optionsToUnset: CMacroEnum...) {
        self.options.subtract(optionsToUnset)
    }
}
