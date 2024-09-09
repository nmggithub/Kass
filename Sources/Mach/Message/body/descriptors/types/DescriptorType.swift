import Darwin.Mach

extension Mach.Message.Body {
    /// A descriptor type.
    public enum DescriptorType: mach_msg_descriptor_type_t {
        case port = 0
        case ool = 1
        case oolPorts = 2
        case oolVolatile = 3
        case guardedPort = 4
        /// The struct type for the raw descriptor type.
        internal var swiftStructType: any Mach.Message.Body.Descriptor.Type {
            switch self {
            case .port: return PortDescriptor.self
            case .ool: return OOLDescriptor.self
            case .oolPorts: return OOLPortsDescriptor.self
            case .oolVolatile: return OOLDescriptor.self
            case .guardedPort: return GuardedPortDescriptor.self
            }
        }
    }
}
