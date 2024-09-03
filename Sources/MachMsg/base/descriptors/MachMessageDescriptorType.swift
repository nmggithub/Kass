import CCompat
import Darwin.Mach

/// A descriptor type.
public enum MachMessageDescriptorType: mach_msg_descriptor_type_t, CBinIntMacroEnum, Sendable {
    case port = 0
    case ool = 1
    case oolPorts = 2
    case oolVolatile = 3
    case guardedPort = 4
    /// The struct type for the raw descriptor type.
    internal var swiftStructType: any MachMessageDescriptor.Type {
        switch self {
        case .port: return PortDescriptor.self
        case .ool: return OOLDescriptor.self
        case .oolPorts: return OOLPortsDescriptor.self
        case .oolVolatile: return OOLDescriptor.self
        case .guardedPort: return GuardedPortDescriptor.self
        }
    }
    /// The name of the C macro that represents the descriptor type.
    public var cMacroName: String {
        "MACH_MSG_"
            + "\(self)".replacingOccurrences(
                of: "([a-z])([A-Z])", with: "$1_$2", options: .regularExpression
            )
            .uppercased() + "_DESCRIPTOR"
    }
}
