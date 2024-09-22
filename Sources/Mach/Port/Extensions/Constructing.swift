import CCompat
import Darwin.Mach

extension Mach.Port {
    /// A flag to use when constructing a port.
    public enum ConstructFlag: UInt32 {
        case contextAsGuard = 0x01
        case queueLimit = 0x02
        case tempOwner = 0x04
        case importanceReceiver = 0x08
        case insertSendRight = 0x10
        case strict = 0x20
        case denapReceiver = 0x40
        case immovableReceive = 0x80
        case filterMsg = 0x100
        case tgBlockTracking = 0x200
        case servicePort = 0x400
        case connectionPort = 0x800
        case replyPort = 0x1000
        case replyPortSemantics = 0x2000
        case provisionalReplyPort = 0x4000
        case provisionalIdProtOutput = 0x8000
    }
    /// Constructs a new port with the given options.
    /// - Parameters:
    ///   - queueLimit: The maximum number of messages that can be queued.
    ///   - flags: The flags to use when constructing the port.
    ///   - context: The context to associate with the port.
    ///   - task: The task to construct the port in.
    /// - Important: The `context` parameter is only used to guard the port (and only if the
    /// ``ConstructFlag/contextAsGuard`` flag is passed).
    public convenience init(
        queueLimit: mach_port_msgcount_t, flags: Set<ConstructFlag>,
        context: mach_port_context_t = mach_port_context_t(),
        in task: Mach.Task = .current
    ) throws {
        var generatedPortName = mach_port_name_t()
        var options = mach_port_options_t()
        options.mpl.mpl_qlimit = queueLimit
        options.flags = flags.bitmap()
        try Mach.call(mach_port_construct(task.name, &options, context, &generatedPortName))
        self.init(named: mach_port_name_t(generatedPortName))
    }

    /// Destructs the port.
    /// - Parameters:
    ///   - sendRightDelta: The delta to apply to the send right user ref count.
    ///   - guard: The context to unguard the port with.
    /// - Throws: If the port cannot be destructed.
    public func destruct(
        guard: mach_port_context_t = mach_port_context_t(), sendRightDelta: mach_port_delta_t
    ) throws {
        try Mach.call(
            mach_port_destruct(self.owningTask.name, self.name, sendRightDelta, `guard`)
        )
    }
}
