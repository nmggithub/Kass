import CCompat
import Darwin.Mach
import Foundation

/// MARK: - Descriptor
extension Mach {
    /// A descriptor for a message body.
    public protocol MessageDescriptor {}

}

extension Mach.MessageDescriptor {
    /// The size of the descriptor in bytes.
    public static var size: Int { MemoryLayout<Self>.size }

    /// The size of the descriptor in bytes.
    public var size: Int { MemoryLayout<Self>.size }
}

/// MARK: - Descriptor Type
extension Mach {
    /// A descriptor type.
    public struct MessageDescriptorType: Mach.OptionEnum {
        /// The raw descriptor type.
        public let rawValue: mach_msg_descriptor_type_t

        /// Represents a raw descriptor type.
        public init(rawValue: mach_msg_descriptor_type_t) { self.rawValue = rawValue }

        /// Whether the descriptor type is a valid type.
        public var isValid: Bool {
            switch self {
            case .port, .ool, .oolPorts, .oolVolatile, .guardedPort: return true
            default: return false
            }
        }

        /// The port descriptor type.
        public static let port = Self(
            rawValue: mach_msg_descriptor_type_t(MACH_MSG_PORT_DESCRIPTOR)
        )

        /// The OOL descriptor type.
        public static let ool = Self(
            rawValue: mach_msg_descriptor_type_t(MACH_MSG_OOL_DESCRIPTOR)
        )

        /// The OOL ports descriptor type.
        public static let oolPorts = Self(
            rawValue: mach_msg_descriptor_type_t(MACH_MSG_OOL_PORTS_DESCRIPTOR)
        )

        /// The volatile OOL descriptor type.
        public static let oolVolatile = Self(
            rawValue: mach_msg_descriptor_type_t(MACH_MSG_OOL_VOLATILE_DESCRIPTOR)
        )

        /// The guarded port descriptor type.
        public static let guardedPort = Self(
            rawValue: mach_msg_descriptor_type_t(MACH_MSG_GUARDED_PORT_DESCRIPTOR)
        )

        /// The struct type for the raw descriptor type.
        internal var structType: any Mach.MessageDescriptor.Type {
            switch self {
            case .port: return mach_msg_port_descriptor_t.self
            case .ool: return mach_msg_ool_descriptor_t.self
            case .oolPorts: return mach_msg_ool_ports_descriptor_t.self
            case .oolVolatile: return mach_msg_ool_descriptor_t.self
            case .guardedPort: return mach_msg_guarded_port_descriptor_t.self
            default: fatalError("Invalid descriptor type: \(self)")
            }
        }
    }
}

/// MARK: - Port Descriptor
extension mach_msg_port_descriptor_t: Mach.MessageDescriptor {
    /// The port.
    public var port: Mach.Port {
        get { Mach.Port(named: self.name) }
        set { self.name = newValue.name }
    }

    /// The port disposition.
    public var portDisposition: Mach.PortDisposition {
        get { Mach.PortDisposition(rawValue: self.disposition) }
        set { self.disposition = newValue.rawValue }
    }

    /// Creates a new port descriptor.
    public init(_ port: Mach.Port, disposition: Mach.PortDisposition) {
        self.init(
            name: port.name,
            pad1: 0, pad2: 0,
            disposition: disposition.rawValue,
            type: Mach.MessageDescriptorType.port.rawValue
        )
    }
}

/// MARK: - Port Guard Flag
extension Mach {
    /// A flag for guarding a port in a message.
    public struct MessagePortGuardFlag: Mach.FlagEnum {
        /// The raw flag value.
        public let rawValue: mach_msg_guard_flags_t

        /// Represents a raw flag value.
        public init(rawValue: mach_msg_guard_flags_t) { self.rawValue = rawValue }

        public static let immovableReceive = Self(
            rawValue: mach_msg_guard_flags_t(MACH_MSG_GUARD_FLAGS_IMMOVABLE_RECEIVE)
        )

        public static let unguardedOnSend = Self(
            rawValue: mach_msg_guard_flags_t(MACH_MSG_GUARD_FLAGS_UNGUARDED_ON_SEND)
        )
    }
}

/// MARK: - Guarded Port
extension mach_msg_guarded_port_descriptor_t: Mach.MessageDescriptor {
    /// The port.
    public var port: Mach.Port {
        get { Mach.Port(named: self.name) }
        set { self.name = newValue.name }
    }

    /// The port disposition.
    public var portDisposition: Mach.PortDisposition {
        get { Mach.PortDisposition(rawValue: self.disposition) }
        set { self.disposition = newValue.rawValue }
    }

    /// Creates a new port descriptor.
    public init(
        _ port: Mach.Port, disposition: Mach.PortDisposition, context: mach_port_context_t = 0,
        guardFlags: Set<Mach.MessagePortGuardFlag> = []
    ) {
        self.init(
            context: context,
            flags: guardFlags.bitmap(),
            disposition: disposition.rawValue,
            type: Mach.MessageDescriptorType.guardedPort.rawValue,
            name: port.name
        )
    }
}

/// MARK: - OOL Copy Option
extension Mach {
    /// A copy option for OOL descriptors.
    public struct OOLDescriptorCopyOption: OptionEnum {
        /// The raw copy option.
        public let rawValue: mach_msg_copy_options_t

        /// Represents a raw copy option.
        public init(rawValue: mach_msg_copy_options_t) { self.rawValue = rawValue }

        public static let physical = Self(rawValue: mach_msg_copy_options_t(MACH_MSG_PHYSICAL_COPY))
        public static let virtual = Self(rawValue: mach_msg_copy_options_t(MACH_MSG_VIRTUAL_COPY))
        public static let allocate = Self(rawValue: mach_msg_copy_options_t(MACH_MSG_ALLOCATE))
        public static let overwrite = Self(rawValue: mach_msg_copy_options_t(MACH_MSG_OVERWRITE))
    }
}

/// MARK: - OOL Descriptor
extension mach_msg_ool_descriptor_t: Mach.MessageDescriptor {
    /// The copy option.
    public var copyOption: Mach.OOLDescriptorCopyOption {
        get { Mach.OOLDescriptorCopyOption(rawValue: self.copy) }
        set { self.copy = newValue.rawValue }
    }

    /// The data of the descriptor.
    public var data: Data? {
        address.map {
            Data(bytes: $0, count: Int(size))
        }
    }

    /// Whether to deallocate the data on send.
    public var deallocateOnSend: Bool {
        get { deallocate != 0 }
        set { deallocate = newValue ? 1 : 0 }
    }

    /// Whether the data is volatile.
    /// - Warning: This property accessor will crash the program if the descriptor type is not `.ool` or `.oolVolatile`.
    public var isVolatile: Bool {
        get {
            switch type {
            case Mach.MessageDescriptorType.oolVolatile.rawValue: return true
            case Mach.MessageDescriptorType.ool.rawValue: return false
            default: fatalError("Invalid OOL descriptor type: \(type)")
            }
        }
        set {
            type =
                newValue
                ? Mach.MessageDescriptorType.oolVolatile.rawValue
                : Mach.MessageDescriptorType.ool.rawValue
        }
    }

    /// Creates a new OOL descriptor.
    public init(
        _ data: Data, copyOption: Mach.OOLDescriptorCopyOption = .virtual,
        deallocateOnSend: Bool = false
    ) {
        self.init(
            address: UnsafeMutableRawPointer(mutating: (data as NSData).bytes),
            deallocate: deallocateOnSend ? 1 : 0,
            copy: copyOption.rawValue,
            pad1: 0,
            type: Mach.MessageDescriptorType.ool.rawValue,
            size: mach_msg_size_t(data.count)
        )
    }
}

/// MARK: - OOL Ports Descriptor
extension mach_msg_ool_ports_descriptor_t: Mach.MessageDescriptor {
    /// The ports.
    /// - Important: Setting this property will allocate a new buffer for the ports. Deallocation of
    /// it, the old buffer, and the ports within the old buffer is the responsibility of the caller.
    public var ports: [Mach.Port] {
        get {
            let portsBuffer = UnsafeBufferPointer(
                start: self.address.bindMemory(
                    to: mach_port_t.self, capacity: Int(self.count)),
                count: Int(self.count)
            )
            return Array(portsBuffer).map({ portName in Mach.Port(named: portName) })
        }
        set {
            let portsPointer = UnsafeMutablePointer<mach_port_t>.allocate(capacity: newValue.count)
            portsPointer.initialize(from: newValue.map(\.name), count: newValue.count)
            self.address = UnsafeMutableRawPointer(portsPointer)
            self.count = mach_msg_size_t(newValue.count)
        }
    }

    /// The disposition.
    public var portsDisposition: Mach.PortDisposition {
        get { Mach.PortDisposition(rawValue: self.disposition) }
        set { self.disposition = newValue.rawValue }
    }

    /// Whether to deallocate the ports on send.
    public var deallocateOnSend: Bool {
        get { self.deallocate != 0 }
        set { self.deallocate = newValue ? 1 : 0 }
    }

    /// The copy method.
    public var copyMethod: Mach.OOLDescriptorCopyOption {
        get { Mach.OOLDescriptorCopyOption(rawValue: self.copy) }
        set { self.copy = newValue.rawValue }
    }

    /// Creates a new OOL ports descriptor.
    public init(
        _ ports: [Mach.Port], disposition: Mach.PortDisposition,
        copyMethod: Mach.OOLDescriptorCopyOption,
        deallocateOnSend: Bool = false
    ) {
        self.init(
            address: nil,
            deallocate: deallocateOnSend ? 1 : 0,
            copy: copyMethod.rawValue,
            disposition: disposition.rawValue,
            type: Mach.MessageDescriptorType.oolPorts.rawValue,
            count: mach_msg_size_t(ports.count)
        )
        self.ports = ports
    }
}

/// MARK: - Descriptor Iterator
extension Mach {
    public struct MessageDescriptorIterator: IteratorProtocol {
        /// The element type.
        public typealias Element = any Mach.MessageDescriptor

        /// The count of descriptors.
        private let count: Int

        /// The current index.
        private var index: Int = 0

        /// The current descriptor pointer.
        /// - Note: Each descriptor structure can be cast as a `mach_msg_type_descriptor_t` to get the type.
        private var pointer: UnsafePointer<mach_msg_type_descriptor_t>

        /// Creates an iterator for a set of descriptor pointers.
        init(bodyPointer: UnsafePointer<mach_msg_body_t>) {
            self.count = Int(bodyPointer.pointee.msgh_descriptor_count)
            self.pointer = UnsafeRawPointer(bodyPointer + 1)
                .bindMemory(to: mach_msg_type_descriptor_t.self, capacity: 1)
        }

        /// Deserializes a descriptor from a pointer.
        /// - Note: This has to be a separate function because the type of the descriptor is not known at compile time.
        private static func deserialize<DescriptorType: Mach.MessageDescriptor>(
            type: DescriptorType.Type,
            fromPointer descriptorPointer: UnsafePointer<mach_msg_type_descriptor_t>
        ) -> DescriptorType { UnsafeRawPointer(descriptorPointer).load(as: DescriptorType.self) }

        /// Advances to the next descriptor and returns it, or `nil` if there are no more descriptors.
        /// - Warning: This function also returns `nil` if the type of the next descriptor is invalid.
        public mutating func next() -> Element? {
            guard self.index < self.count else { return nil }  // No more descriptors.
            let rawDescriptorType = self.pointer.pointee.type
            let descriptorType = Mach.MessageDescriptorType(rawValue: rawDescriptorType)
            guard descriptorType.isValid else { return nil }
            let descriptorPointer = self.pointer
            self.pointer = (UnsafeRawPointer(self.pointer) + descriptorType.structType.size)
                .bindMemory(to: mach_msg_type_descriptor_t.self, capacity: 1)
            self.index += 1
            return Self.deserialize(type: descriptorType.structType, fromPointer: descriptorPointer)
        }
    }
}
