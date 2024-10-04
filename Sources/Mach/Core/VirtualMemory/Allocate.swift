import Darwin.Mach

extension Mach {
    /// Flags for allocating memory.
    public struct VMAllocationFlags: OptionSet, Sendable, Mach.NamedOptionEnum {
        /// Represents a raw flag with an optional name.
        public init(name: String?, rawValue: Int32) {
            self.name = name
            self.rawValue = rawValue
        }

        /// The name of the flag, if it can be determined.
        public let name: String?

        /// All known allocation flags.
        public static let allCases: [Self] = [
            .fixed, .anywhere, .purgable, .fourGBChunk, .randomAddress, .noCache,
            .resilientCodesign, .resilientMedia, .permanent, .trpo, .overwrite,
        ]

        /// The raw value of the flag.
        public var rawValue: Int32

        /// - Note the ``anywhere`` flag overrides this flag.
        public static let fixed = Self(name: "fixed", rawValue: VM_FLAGS_FIXED)

        public static let anywhere = Self(name: "anywhere", rawValue: VM_FLAGS_ANYWHERE)

        /// - Note: The apparent typo is copied from the original source.
        public static let purgable = Self(name: "purgable", rawValue: VM_FLAGS_PURGABLE)

        /// - Note: Case names cannot start with a number, so the number is spelled out.
        public static let fourGBChunk = Self(name: "fourGBChunk", rawValue: VM_FLAGS_4GB_CHUNK)

        public static let randomAddress = Self(
            name: "randomAddress", rawValue: VM_FLAGS_RANDOM_ADDR
        )

        public static let noCache = Self(name: "noCache", rawValue: VM_FLAGS_NO_CACHE)

        public static let resilientCodesign = Self(
            name: "resilientCodesign", rawValue: VM_FLAGS_RESILIENT_CODESIGN
        )

        public static let resilientMedia = Self(
            name: "resilientMedia", rawValue: VM_FLAGS_RESILIENT_MEDIA
        )

        public static let permanent = Self(name: "permanent", rawValue: VM_FLAGS_PERMANENT)

        public static let trpo = Self(name: "trpo", rawValue: VM_FLAGS_TPRO)

        public static let overwrite = Self(name: "overwrite", rawValue: VM_FLAGS_OVERWRITE)
    }
}

extension Mach.Task {
    /// Allocates a new VM region in the task's address space.
    public func allocate(
        address: inout vm_address_t, size: vm_size_t,
        flags: Mach.VMAllocationFlags = []
    ) throws {
        try Mach.call(vm_allocate(self.name, &address, size, flags.rawValue))
    }

    /// Allocates a new VM region of physically contiguous memory in the task's address space.
    /// - Warning: This function makes two kernel calls. Due to this, any error thrown from this
    /// function could be from either call. Please see the source code for more information.
    @available(macOS, obsoleted: 15.0)
    public func allocatePhysicallyContiguous(
        address: inout vm_address_t, size: vm_size_t,
        flags: Mach.VMAllocationFlags = []
    ) throws {
        let taskHost = try self.getSpecialPort(.host)
        try Mach.call(
            vm_allocate_cpm(taskHost.name, self.name, &address, size, flags.rawValue)
        )
    }
}
