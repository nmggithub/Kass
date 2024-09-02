/// A Mach message descriptor.
public protocol MachMessageDescriptor: RawRepresentable where RawValue == CStruct {
    typealias DescriptorType = MachMessageDescriptorType
    /// The raw C struct type for the descriptor.
    associatedtype CStruct
    /// Represent an existing raw descriptor.
    /// - Parameter rawValue: The raw descriptor.
    init(rawValue: CStruct)
    /// Create a new empty descriptor.
    init()
}

extension MachMessageDescriptor {
    /// The size of the descriptor in bytes.
    /// - Note: This is static so that it can be accessed without an instance.
    public static var size: Int { MemoryLayout<Self.CStruct>.size }
    /// The size of the descriptor in bytes.
    /// - Note: This is an instance property so that it can be accessed with an instance.
    public var size: Int { MemoryLayout<Self.CStruct>.size }
}
