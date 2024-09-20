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
