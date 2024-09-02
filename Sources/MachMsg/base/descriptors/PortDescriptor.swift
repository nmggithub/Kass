import MachO
import MachPort

/// A port descriptor.
public struct PortDescriptor: MachMessageDescriptor {
    public typealias CStruct = mach_msg_port_descriptor_t
    public var rawValue: mach_msg_port_descriptor_t {
        mach_msg_port_descriptor_t(
            name: port.rawValue,
            pad1: 0,
            pad2: 0,
            disposition: disposition?.rawValue ?? 0,
            type: DescriptorType.port.rawValue
        )
    }
    /// The port.
    public var port: MachPort
    /// The disposition.
    public var disposition: MachPortDisposition?
    /// Represent an existing raw port descriptor.
    /// - Parameter rawValue: The raw port descriptor.
    public init(rawValue: mach_msg_port_descriptor_t) {
        self.port = .init(rawValue: rawValue.name)
        self.disposition = .init(rawValue: rawValue.disposition)
    }
    /// Create a new port descriptor.
    public init() {
        self.port = nil
        self.disposition = nil
    }
    /// Create a new port descriptor with a port.
    /// - Parameters:
    ///   - port: The port.
    ///   - disposition: The disposition.
    public init(_ port: MachPort, disposition: MachPortDisposition? = nil) {
        self.port = port
        self.disposition = disposition
    }
}
