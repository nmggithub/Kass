import Darwin.Mach
import MachBase
import MachPort

extension Mach.Message.Body.Descriptor {
    /// A port descriptor.
    public typealias Port = Mach.Message.Body.PortDescriptor
}

extension Mach.Message.Body {
    /// A port descriptor.
    public struct PortDescriptor: Descriptor {
        public typealias CStruct = mach_msg_port_descriptor_t
        public var rawValue: mach_msg_port_descriptor_t {
            mach_msg_port_descriptor_t(
                name: port.name,
                pad1: 0,
                pad2: 0,
                disposition: self.disposition?.rawValue ?? 0,
                type: DescriptorType.port.rawValue
            )
        }
        /// The port.
        public var port: Mach.Port
        /// The disposition.
        public var disposition: Mach.Port.Disposition?
        /// Represent an existing raw port descriptor.
        /// - Parameter rawValue: The raw port descriptor
        public init(rawValue: CStruct) {
            self.port = Mach.Port(named: rawValue.name)
            self.disposition = Mach.Port.Disposition(rawValue: rawValue.disposition)
        }
        /// Create a new port descriptor.
        public init() {
            self.port = .init(named: mach_port_t(MACH_PORT_NULL))
            self.disposition = nil
        }
        /// Create a new port descriptor.
        /// - Parameters:
        ///   - port: The port.
        ///   - disposition: The disposition.
        public init(_ port: Mach.Port, disposition: Mach.Port.Disposition) {
            self.port = port
            self.disposition = disposition
        }
    }
}