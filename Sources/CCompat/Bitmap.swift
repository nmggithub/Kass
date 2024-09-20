extension CaseIterable where Self: RawRepresentable, Self: Hashable, Self.RawValue: BinaryInteger {
    /// Create a set of options from a bitmap.
    /// - Parameter bitmap: The bitmap.
    /// - Returns: The set of options.
    public static func setFromBitmap(_ bitmap: Self.RawValue) -> Set<Self> {
        Set(
            Self.allCases.filter { bitmap & $0.rawValue != 0 }
        )
    }
}

extension Set where Element: RawRepresentable, Element.RawValue: BinaryInteger {
    /// Create a bitmap from a set of options.
    /// - Parameter options: The options.
    /// - Returns: The bitmap.
    public func bitmap() -> Element.RawValue {
        reduce(0) { $0 | $1.rawValue }
    }
}
