extension CaseIterable where Self: RawRepresentable, Self: Hashable, Self.RawValue: BinaryInteger {
    /// Creates a set of options from a bitmap.
    /// - Parameter bitmap: The bitmap.
    /// - Returns: The set of options.
    public static func set(from bitmap: Self.RawValue) -> Set<Self> {
        Set(Self.allCases.filter { bitmap & $0.rawValue != 0 })
    }
}

extension Set where Element: RawRepresentable, Element.RawValue: BinaryInteger {
    /// Creates a bitmap from the given set of options.
    /// - Returns: The bitmap.
    public func bitmap() -> Element.RawValue { reduce(0) { $0 | $1.rawValue } }
}
