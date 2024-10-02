import Darwin.Mach

extension Mach.VM {
    /// Flags for allocating memory.
    public struct AllocationFlags: OptionSet, Sendable {
        public var rawValue: Int32
        public init(rawValue: Int32) { self.rawValue = rawValue }

        /// - Note the ``anywhere`` flag overrides this flag.
        public static let fixed = Self(rawValue: VM_FLAGS_FIXED)

        /// Allocate new VM region anywhere it would fit in the address space.
        public static let anywhere = Self(rawValue: VM_FLAGS_ANYWHERE)

        /// - Note: The apparent typo is copied from the original source.
        public static let purgable = Self(rawValue: VM_FLAGS_PURGABLE)

        /// - Note: Case names cannot start with a number, so the number is spelled out.
        public static let fourGBChunk = Self(rawValue: VM_FLAGS_4GB_CHUNK)

        public static let randomAddress = Self(rawValue: VM_FLAGS_RANDOM_ADDR)

        public static let noCache = Self(rawValue: VM_FLAGS_NO_CACHE)

        public static let resilientCodesign = Self(rawValue: VM_FLAGS_RESILIENT_CODESIGN)

        public static let resilientMedia = Self(rawValue: VM_FLAGS_RESILIENT_MEDIA)

        public static let permanent = Self(rawValue: VM_FLAGS_PERMANENT)

        public static let trpo = Self(rawValue: VM_FLAGS_TPRO)

        public static let overwrite = Self(rawValue: VM_FLAGS_OVERWRITE)
    }
    /// Allocates a new VM region in the task's address space.
    /// - Warning: The call to allocate contiguous physical memory requires a host port. This function uses the task's host
    /// port, but the process of getting the host port may fail. Errors in that process are thrown from this function.
    public static func allocate(
        task: Mach.Task = .current,
        address: inout vm_address_t, size: vm_size_t,
        flags: Mach.VM.AllocationFlags = [],
        contiguous: Bool = false
    ) throws {
        if contiguous {
            let taskHost = try task.getSpecialPort(.host)
            try Mach.call(
                vm_allocate_cpm(taskHost.name, task.name, &address, size, flags.rawValue)
            )
        } else {
            try Mach.call(vm_allocate(task.name, &address, size, flags.rawValue))
        }
    }
}
