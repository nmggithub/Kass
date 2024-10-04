import Darwin.Mach

extension Mach {
    /// A protection option for virtual memory.
    public struct VMProtectionOptions: OptionSet, Mach.NamedOptionEnum {

        /// Represents a raw protection option with an optional name.
        public init(name: String? = nil, rawValue: vm_prot_t) {
            self.name = name
            self.rawValue = rawValue
        }

        public var name: String?

        public static let allCases: [Self] = [.none, .read, .write, .execute]

        /// The raw value of the protection option.
        public let rawValue: vm_prot_t

        /// - Important: This case has no effect when used with other protection options.
        public static let none = Self(name: "none", rawValue: VM_PROT_NONE)

        /// The memory is readable.
        public static let read = Self(name: "read", rawValue: VM_PROT_READ)

        /// The memory is writable.
        public static let write = Self(name: "write", rawValue: VM_PROT_WRITE)

        /// The memory is executable.
        public static let execute = Self(name: "execute", rawValue: VM_PROT_EXECUTE)
    }
}

extension Mach.Task {
    /// The host port for use with the `vm_wire` kernel call.
    private var hostForVMWire: Mach.Host {
        get throws {
            if #available(macOS 11.3, *) {
                // On macOS 11.3 and later, the kernel only checks if the host port is non-nil.
                return .init(named: 1)  // Any name besides zero is considered a non-nil name.
            } else {
                // Prior to macOS 11.3, the kernel checks if the host port is actually the expected host port.
                return try self.getSpecialPort(.host)
            }
        }
    }
    /// Wires a range of memory.
    /// - Warning: This function may make an additional kernel call. Errors from this
    /// call are also thrown. Please see the source code for more information.
    public func wireMemory(
        _ address: vm_address_t, size: vm_size_t,
        options: Mach.VMProtectionOptions
    ) throws {
        guard !options.isEmpty && options != [.none] else {
            // specifying no access protection actually unwires the memory, which we don't want.
            fatalError("Please specify at least one access protection.")
        }
        let host = try hostForVMWire
        try Mach.call(
            vm_wire(host.name, self.name, address, size, options.rawValue)
        )
    }

    /// Unwires a range of memory.
    /// - Warning: This function may make an additional kernel call. Errors from this
    /// call are also thrown. Please see the source code for more information.
    public func unwireMemory(
        _ address: vm_address_t, size: vm_size_t
    ) throws {
        let options: Mach.VMProtectionOptions = [.none]
        let host = try hostForVMWire
        try Mach.call(
            vm_wire(host.name, self.name, address, size, options.rawValue)
        )
    }
}
