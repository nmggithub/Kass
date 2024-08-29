import CCompat
import Darwin
import Foundation

/// A descriptor type.
public enum DescriptorType: mach_msg_descriptor_type_t, NameableByCMacro, Sendable {
    case port = 0
    case ool = 1
    case oolPorts = 2
    case oolVolatile = 3
    case guardedPort = 4

    /// The name of the C macro that represents the descriptor type.
    public var cMacroName: String {
        "MACH_MSG_"
            + "\(self)".replacingOccurrences(
                of: "([a-z])([A-Z])", with: "$1_$2", options: .regularExpression
            )
            .uppercased() + "_DESCRIPTOR"
    }
}

/// A Mach message descriptor.
public protocol MachMessageDescriptor: RawRepresentable {
    /// The raw descriptor type.
    typealias RawDescriptorType = RawValue
    /// The raw descriptor.
    var rawValue: RawDescriptorType { get }
    /// The type of the descriptor.
    static var type: DescriptorType { get }
    /// Initialize a new descriptor.
    /// - Parameter rawValue: The raw descriptor.
    init(rawValue: RawDescriptorType)
}

// Stored values for Mach message descriptors (stored values cannot be defined in protocols, so we use an extension)
extension MachMessageDescriptor {
    /// The size of the descriptor in bytes.
    /// - Remark: This is static so that it can be accessed without an instance.
    public static var size: Int { MemoryLayout<Self.RawDescriptorType>.size }
    /// The size of the descriptor in bytes.
    /// - Remark: This is an instance property so that it can be accessed with an instance.
    public var size: Int { MemoryLayout<Self.RawDescriptorType>.size }
    /// The type of the descriptor.
    public var type: DescriptorType { Self.type }
}

/// A port descriptor.
public struct PortDescriptor: MachMessageDescriptor {
    public let rawValue: mach_msg_port_descriptor_t
    public static let type: DescriptorType = .port
    public init(rawValue: mach_msg_port_descriptor_t) {
        self.rawValue = rawValue
    }
    /// The port.
    public var port: MachMessagePort {
        .init(
            rawPort: self.rawValue.name,
            disposition: .init(rawValue: self.rawValue.disposition)!
        )
    }
    /// Initialize a new port descriptor.
    /// - Parameter port: The port.
    public init(port: MachMessagePort) {
        self.rawValue = mach_msg_port_descriptor_t(
            name: port.rawValue,
            pad1: 0,
            pad2: 0,
            disposition: port.disposition.rawValue,
            type: DescriptorType.port.rawValue
        )
    }
}

/// A copy option.
/// - Remark: This is used for out-of-line descriptors.
public enum CopyOption: mach_msg_copy_options_t, NameableByCMacro {
    case physical = 0
    case virtual = 1
    case allocate = 2
    case overwrite = 3  // deprecated
    case kallocCopy = 4  // kernel only
    public var cMacroName: String {
        switch self {
        case .physical: return "MACH_MSG_PHYSICAL_COPY"
        case .virtual: return "MACH_MSG_VIRTUAL_COPY"
        case .allocate: return "MACH_MSG_ALLOCATE"
        case .overwrite: return "MACH_MSG_OVERWRITE"
        case .kallocCopy: return "MACH_MSG_KALLOC_COPY_T"
        }
    }
}

/// An out-of-line data descriptor.
public struct OOLDescriptor: MachMessageDescriptor {
    public let rawValue: mach_msg_ool_descriptor_t
    public static let type: DescriptorType = .ool
    public init(rawValue: mach_msg_ool_descriptor_t) {
        self.rawValue = rawValue
    }
    /// The data.
    public var data: Data? {
        guard self.rawValue.address != nil else { return nil }
        return Data(bytes: self.rawValue.address, count: Int(self.rawValue.size))
    }
    /// Initialize a new out-of-line data descriptor.
    /// - Parameters:
    ///   - data: The data.
    ///   - deallocate: Whether to deallocate the data.
    ///   - copyMethod: The copy method.
    ///   - isVolatile: Whether the descriptor is volatile.
    public init(
        data: Data, deallocate: Bool = false, copyMethod: CopyOption = .physical,
        isVolatile: Bool = false
    ) {
        self.init(
            address: UnsafeMutableRawPointer(mutating: (data as NSData).bytes),
            size: mach_msg_size_t(data.count),
            deallocate: deallocate,
            copyMethod: copyMethod,
            isVolatile: isVolatile
        )
    }
    /// Initialize a new out-of-line data descriptor.
    /// - Parameters:
    ///  - address: The address of the data.
    /// - size: The size of the data.
    /// - deallocate: Whether to deallocate the data.
    /// - copyMethod: The copy method.
    /// - isVolatile: Whether the descriptor is volatile.
    public init(
        address: UnsafeMutableRawPointer,
        size: mach_msg_size_t,
        deallocate: Bool = false,
        copyMethod: CopyOption = .physical,
        // volatile descriptors don't appear to be treated any differently by the kernel, but keeping this here for completeness
        isVolatile: Bool = false
    ) {
        self.rawValue = mach_msg_ool_descriptor_t(
            address: address,
            deallocate: deallocate ? 1 : 0,
            copy: copyMethod.rawValue,
            pad1: 0,
            type: isVolatile ? DescriptorType.oolVolatile.rawValue : DescriptorType.ool.rawValue,
            size: size
        )
    }
}

/// An out-of-line ports descriptor.
public struct OOLPortsDescriptor: MachMessageDescriptor {
    public let rawValue: mach_msg_ool_ports_descriptor_t
    public static let type: DescriptorType = .oolPorts
    public init(rawValue: mach_msg_ool_ports_descriptor_t) {
        self.rawValue = rawValue
    }
    /// Initialize a new out-of-line ports descriptor.
    /// - Parameters:
    ///   - ports: The ports.
    ///   - disposition: The disposition of the ports.
    ///   - deallocate: Whether to deallocate the ports.
    ///   - copyMethod: The copy method.
    public init(
        ports: [MachPort],
        disposition: MachMessagePort.Disposition,
        deallocate: Bool = false,
        copyMethod: CopyOption = .physical
    ) {
        let portsPointer = UnsafeMutablePointer<mach_port_t>.allocate(capacity: ports.count)
        portsPointer.initialize(from: ports.map(\.rawValue), count: ports.count)
        self.rawValue = mach_msg_ool_ports_descriptor_t(
            address: portsPointer,
            deallocate: deallocate ? 1 : 0,
            copy: copyMethod.rawValue,
            disposition: disposition.rawValue,
            type: DescriptorType.oolPorts.rawValue,
            count: mach_msg_size_t(ports.count)
        )
        // We could call `.deallocate()` here, but we won't (instead, we'll respect the deallocate flag and let the kernel handle it)
    }
}

/// A guard flag.
public enum GuardFlag: mach_msg_guard_flags_t, COptionMacroEnum {
    case none = 0
    case immovableReceive = 1
    case unguardedOnSend = 2
    public var cMacroName: String {
        "MACH_MSG_GUARD_FLAGS_"
            + "\(self)".replacingOccurrences(
                of: "([a-z])([A-Z])", with: "$1_$2", options: .regularExpression
            )
            .uppercased()
    }
}

/// A set of guard flags.
public typealias GuardFlags = COptionMacroSet<GuardFlag>

/// A guarded port descriptor.
public struct GuardedPortDescriptor: MachMessageDescriptor {
    public let rawValue: mach_msg_guarded_port_descriptor_t
    public static let type: DescriptorType = .guardedPort
    public init(rawValue: mach_msg_guarded_port_descriptor_t) {
        self.rawValue = rawValue
    }
    /// Initialize a new guarded port descriptor.
    /// - Parameters:
    ///   - port: The port.
    ///   - guardValue: The guard value.
    ///   - flags: The guard flags.
    public init(port: MachMessagePort, guardValue: UInt, flags: GuardFlags = []) {
        self.rawValue = mach_msg_guarded_port_descriptor_t(
            context: guardValue,  // this seems to use the context field for the guard value (will probably fail if there is already context data)
            flags: flags.rawValue,
            disposition: port.disposition.rawValue,
            type: DescriptorType.guardedPort.rawValue,
            name: port.rawValue
        )
    }
}

/// A set of descriptors at a pointer.
public class MachMessageDescriptors {
    private let bodyPointer: UnsafeMutablePointer<mach_msg_body_t>
    /// The pointer to the descriptors.
    private var pointer: UnsafeRawPointer { UnsafeRawPointer(bodyPointer + 1) }
    /// The types of the descriptors (used for deserialization).
    private let types: [any MachMessageDescriptor.Type]
    /// The size of the descriptors in bytes.
    public var size: Int {
        MemoryLayout<mach_msg_body_t>.size + self.types.reduce(0) { $0 + $1.size }
    }

    /// Deserialize a descriptor from a pointer.
    /// - Parameters:
    ///   - type: The type of the descriptor to deserialize.
    ///   - pointer: The pointer to the descriptor.
    /// - Returns: The deserialized descriptor.
    private static func deserializeDescriptor(
        type: (some MachMessageDescriptor).Type,
        pointer: UnsafeMutableRawPointer
    ) -> some MachMessageDescriptor {
        let rawDescriptor = pointer.bindMemory(to: type.RawDescriptorType.self, capacity: 1)
            .pointee
        return type.init(rawValue: rawDescriptor)
    }

    /// Serialize a descriptor to a pointer.
    /// - Parameters:
    ///   - descriptor: The descriptor to serialize.
    ///   - pointer: The pointer to serialize the descriptor to.
    private static func serializeDescriptor(
        descriptor: some MachMessageDescriptor, pointer: UnsafeMutableRawPointer
    ) {
        pointer.storeBytes(of: descriptor.rawValue, as: type(of: descriptor.rawValue))
    }

    /// The descriptors at the pointer.
    /// - Warning: The type of the descriptors must match the types provided in the initializer.
    public var list: [any MachMessageDescriptor] {
        get {
            var mutablePointer = UnsafeMutableRawPointer(mutating: self.pointer)
            var descriptors: [any MachMessageDescriptor] = []
            for type in self.types {
                let descriptor = Self.deserializeDescriptor(type: type, pointer: mutablePointer)
                descriptors.append(descriptor)
                mutablePointer += type.size
            }
            return descriptors
        }
        set {
            var mutablePointer = UnsafeMutableRawPointer(mutating: self.pointer)
            for descriptor in newValue {
                Self.serializeDescriptor(descriptor: descriptor, pointer: mutablePointer)
                mutablePointer += descriptor.size
            }
            self.bodyPointer.pointee.msgh_descriptor_count = mach_msg_size_t(newValue.count)
        }
    }
    /// Create a new set of descriptors at a pointer.
    /// - Parameters:
    ///   - bodyPointer: The pointer to the complex body of the underlying message.
    ///   - types: The types of the descriptors.
    public init(
        bodyPointer: UnsafeMutablePointer<mach_msg_body_t>, types: [any MachMessageDescriptor.Type]
    ) {
        self.bodyPointer = bodyPointer
        self.types = types
    }

    /// Write a new set of descriptors to a pointer.
    /// - Parameters:
    ///   - bodyPointer: The pointer to the complex body of the underlying message.
    ///   - descriptors: The descriptors.
    public convenience init(
        bodyPointer: UnsafeMutablePointer<mach_msg_body_t>, descriptors: [any MachMessageDescriptor]
    ) {
        self.init(bodyPointer: bodyPointer, types: descriptors.map { type(of: $0) })
        self.list = descriptors
    }
}
