import Darwin.Mach

extension Mach.Port {
    /// Allocates a new port with a given right in the specified task with an optional name.
    public static func allocate(
        right: Mach.PortRight, named name: mach_port_name_t? = nil,
        inNameSpaceOf task: Mach.Task = .current
    ) throws -> Self {
        var generatedPortName = mach_port_name_t()
        try Mach.call(
            name != nil
                ? mach_port_allocate_name(task.name, right.rawValue, name!)
                : mach_port_allocate(task.name, right.rawValue, &generatedPortName)
        )
        return Self(named: name ?? generatedPortName, inNameSpaceOf: task)
    }

    /// Deallocates the port.
    public func deallocate() throws {
        try Mach.call(mach_port_deallocate(self.owningTask.name, self.name))
    }
}

extension Mach.Port {
    /// Constructs a new port with the given flags and limits.

    /// Constructs a new port with the given options.
    public static func construct(
        options: consuming mach_port_options_t,
        context: mach_port_context_t? = nil,
        inNameSpaceOf task: Mach.Task = .current
    ) throws -> Self {
        var generatedPortName = mach_port_name_t()
        if context != nil {
            // We enforce adding this flag if a context is passed, even if the user didn't
            // specify it. The context is ignored otherwise.
            options.flags |= UInt32(Mach.PortConstructFlag.contextAsGuard.rawValue)
        }
        if options.mpl.mpl_qlimit != 0 {
            // We enforce adding this flag is a limit is passed, even if the user didn't
            // specify it. The limit is ignored otherwise.
            options.flags |= UInt32(Mach.PortConstructFlag.queueLimit.rawValue)
        }
        let actualContext = context ?? mach_port_context_t()
        try Mach.call(
            mach_port_construct(task.name, &options, actualContext, &generatedPortName)
        )
        return Self(named: generatedPortName, inNameSpaceOf: task)
    }

    public static func construct(
        flags: Set<Mach.PortConstructFlag>, limits: mach_port_limits = mach_port_limits(),
        inNameSpaceOf task: Mach.Task = .current
    ) throws -> Self {
        var options = mach_port_options_t()
        options.flags = UInt32(flags.bitmap())
        options.mpl = limits
        return try Self.construct(options: options, context: nil, inNameSpaceOf: task)
    }

    /// Destructs the port.
    /// - Parameters:
    ///   - guard: The context to unguard the port with.
    ///   - sendRightDelta: The delta to apply to the send right user reference count.
    /// - Throws: If the port cannot be destructed.
    public func destruct(
        guard: mach_port_context_t = mach_port_context_t(), sendRightDelta: mach_port_delta_t
    ) throws {
        try Mach.call(
            mach_port_destruct(self.owningTask.name, self.name, sendRightDelta, `guard`)
        )
    }
}
