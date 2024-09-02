import MachO
import MachPort

/// An out-of-line ports descriptor.
public struct OOLPortsDescriptor: MachMessageDescriptor {
    public typealias CStruct = mach_msg_ool_ports_descriptor_t
    /// The raw out-of-line ports descriptor.
    public var rawValue: mach_msg_ool_ports_descriptor_t {
        let portsPointer = UnsafeMutablePointer<mach_port_t>.allocate(capacity: ports.count)
        portsPointer.initialize(from: ports.map(\.rawValue), count: ports.count)
        return mach_msg_ool_ports_descriptor_t(
            address: portsPointer,
            deallocate: deallocateOnSend ? 1 : 0,
            copy: copyMethod.rawValue,
            disposition: disposition?.rawValue ?? 0,
            type: DescriptorType.oolPorts.rawValue,
            count: mach_msg_size_t(ports.count)
        )
    }
    /// The ports.
    public var ports: [MachPort]
    /// The disposition.
    public var disposition: MachPortDisposition?
    /// Whether to deallocate the ports on send.
    public var deallocateOnSend: Bool
    /// The copy method.
    public var copyMethod: OOLDescriptorCopyOption
    /// Represent an existing raw out-of-line ports descriptor.
    /// - Parameter rawValue: The raw out-of-line ports descriptor.
    public init(rawValue: mach_msg_ool_ports_descriptor_t) {
        self.disposition = MachPortDisposition(rawValue: rawValue.disposition)
        self.deallocateOnSend = rawValue.deallocate != 0
        self.copyMethod = OOLDescriptorCopyOption(rawValue: rawValue.copy) ?? .unknown
        let portsBuffer = UnsafeBufferPointer(
            start: rawValue.address.bindMemory(to: mach_port_t.self, capacity: Int(rawValue.count)),
            count: Int(rawValue.count)
        )
        self.ports = Array(portsBuffer).map(MachPort.init(rawValue:))
    }
    /// Create a new out-of-line ports descriptor.
    public init() {
        self.ports = []
        self.disposition = nil
        self.deallocateOnSend = false
        self.copyMethod = .physical
    }
    /// Create a new out-of-line ports descriptor with ports.
    /// - Parameters:
    ///   - ports: The ports.
    ///   - disposition: The disposition.
    ///   - copyMethod: The copy method.
    ///   - deallocateOnSend: Whether to deallocate the ports on send.
    public init(
        _ ports: [MachPort], disposition: MachPortDisposition? = nil,
        copyMethod: OOLDescriptorCopyOption = .physical, deallocateOnSend: Bool = false
    ) {
        self.ports = ports
        self.disposition = disposition
        self.deallocateOnSend = deallocateOnSend
        self.copyMethod = copyMethod
    }
}
