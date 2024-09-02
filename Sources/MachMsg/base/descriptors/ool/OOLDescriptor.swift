import CCompat
import Foundation
import MachO

/// An out-of-line descriptor.
public struct OOLDescriptor: MachMessageDescriptor {
    public typealias CStruct = mach_msg_ool_descriptor_t
    /// The raw out-of-line descriptor.
    public var rawValue: mach_msg_ool_descriptor_t {
        let dataCopy = self.data?.withUnsafeBytes {
            buffer in
            let bufferCopy = UnsafeMutableRawBufferPointer.allocate(
                byteCount: buffer.count, alignment: 1)
            bufferCopy.copyMemory(from: buffer)
            return bufferCopy
        }
        return mach_msg_ool_descriptor_t(
            address: dataCopy?.baseAddress,
            deallocate: self.deallocateOnSend ? 1 : 0,
            copy: self.copyMethod.rawValue,
            pad1: 0,
            type: DescriptorType.ool.rawValue,
            size: mach_msg_size_t(dataCopy?.count ?? 0)
        )
    }
    /// The copy method.
    public var copyMethod: OOLDescriptorCopyOption
    /// The data.
    public var data: Data?
    /// Whether to deallocate the data on send.
    public var deallocateOnSend: Bool
    /// Whether the data is volatile.
    public var isVolatile: Bool = false
    /// Represent an existing raw out-of-line descriptor.
    /// - Parameter rawValue: The raw out-of-line descriptor.
    public init(rawValue: mach_msg_ool_descriptor_t) {
        self.copyMethod = OOLDescriptorCopyOption(rawValue: rawValue.copy) ?? .unknown
        self.data = rawValue.address.map {
            Data(bytes: $0, count: Int(rawValue.size))
        }
        self.deallocateOnSend = rawValue.deallocate != 0
        self.isVolatile = rawValue.type == DescriptorType.oolVolatile.rawValue
    }
    /// Create a new out-of-line descriptor.
    public init() {
        self.copyMethod = .physical
        self.data = nil
        self.deallocateOnSend = false
    }
    /// Create a new out-of-line descriptor with data.
    /// - Parameters:
    ///   - data: The data.
    ///   - copyMethod: The copy method.
    ///   - deallocateOnSend: Whether to deallocate the data on send.
    public init(
        _ data: Data?, copyMethod: OOLDescriptorCopyOption = .physical,
        deallocateOnSend: Bool = false
    ) {
        self.copyMethod = copyMethod
        self.data = data
        self.deallocateOnSend = deallocateOnSend
    }
}
