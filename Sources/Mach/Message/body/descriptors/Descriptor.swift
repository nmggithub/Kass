import Darwin.Mach
import MachBase

extension Mach.Message.Body {
    /// A descriptor in a body.
    public protocol Descriptor: RawRepresentable where RawValue == CStruct {
        /// A pointer to a Mach message descriptor.
        /// - Note: All Mach message descriptors can be cast to `mach_msg_type_descriptor_t` to get the type.
        typealias Pointer = UnsafePointer<mach_msg_type_descriptor_t>
        /// The raw C struct type for the descriptor.
        associatedtype CStruct
        /// Represent an existing raw descriptor.
        /// - Parameter rawValue: The raw descriptor.
        init(rawValue: CStruct)
        /// Create a new empty descriptor.
        init()
    }
}

extension Mach.Message.Body.Descriptor {
    /// The size of the descriptor in bytes.
    /// - Note: This is static so that it can be accessed without an instance.
    public static var size: Int { MemoryLayout<Self.CStruct>.size }
    /// The size of the descriptor in bytes.
    /// - Note: This is an instance property so that it can be accessed with an instance.
    public var size: Int { MemoryLayout<Self.CStruct>.size }
}
