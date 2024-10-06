import Darwin.Mach

extension Mach.Exception {
    /// Gets the exception ports for the port's kernel object that catch the exception types specified by the mask.
    fileprivate static func exceptionPorts(
        forPort port: Mach.PortWithExceptionPorts, mask: Mach.ExceptionMask
    ) throws -> [Mach.Exception] {
        var exceptionPorts: [Mach.Exception] = []
        let maxCount = 32  // The mask is a 32-bit integer, so we can have at most 32 exception ports (one for each bit).
        let masks = exception_mask_array_t.allocate(capacity: maxCount)
        let handlers = exception_handler_array_t.allocate(capacity: maxCount)
        let behaviors = exception_behavior_array_t.allocate(capacity: maxCount)
        let flavors = thread_state_flavor_array_t.allocate(capacity: maxCount)
        defer {
            // We can deallocate the arrays once we're done with them, as they only contain trivial types (which we implicitly copy into our `Mach.Exception` ports).
            masks.deallocate()
            handlers.deallocate()
            behaviors.deallocate()
            flavors.deallocate()
        }
        var count = mach_msg_type_number_t(0)
        let getExceptionPortsCall:
            @convention(c) (
                mach_port_name_t, exception_mask_t, exception_mask_array_t?,
                UnsafeMutablePointer<mach_msg_type_number_t>?, exception_handler_array_t?,
                exception_behavior_array_t?, thread_state_flavor_array_t?
            ) -> kern_return_t =
                switch port {
                case is Mach.Task: task_get_exception_ports
                case is Mach.Thread: thread_get_exception_ports
                case is Mach.Host: host_get_exception_ports
                default:
                    fatalError("Unsupported port type.")
                }

        try Mach.call(
            getExceptionPortsCall(
                port.name, mask.rawValue,
                masks, &count, handlers, behaviors, flavors
            )
        )
        guard count > 0 else { return [] }  // We don't need to loop if there are no exception ports.
        guard count <= maxCount else { fatalError("Too many exception ports!") }  // This should never happen, but it's better to be safe than sorry.
        for i in 0..<Int(count) {
            exceptionPorts.append(
                Mach.Exception(
                    named: handlers[i],
                    mask: Mach.ExceptionMask(
                        rawValue: masks[i]
                    ),
                    behavior: Mach.ExceptionBehavior(
                        rawValue: behaviors[i]
                    ),
                    threadStateFlavor: Mach.ThreadStateFlavor(
                        rawValue: flavors[i]
                    )
                )
            )
        }
        return exceptionPorts
    }

    /// Gets the exception ports for the task that catch the exception types specified by the mask.
    public func exceptionPorts(
        forTask task: Mach.Task, mask: Mach.ExceptionMask
    ) throws -> [Mach.Exception] { try Self.exceptionPorts(forPort: task, mask: self.mask) }

    /// Gets the exception ports for the thread that catch the exception types specified by the mask.
    public func exceptionPorts(
        forThread thread: Mach.Thread, mask: Mach.ExceptionMask
    ) throws -> [Mach.Exception] { try Self.exceptionPorts(forPort: thread, mask: self.mask) }

    /// Gets the exception ports for the host that catch the exception types specified by the mask.
    public func exceptionPorts(
        forHost host: Mach.Host, mask: Mach.ExceptionMask
    ) throws -> [Mach.Exception] { try Self.exceptionPorts(forPort: host, mask: self.mask) }

    /// Adds an exception port to the port's kernel object.
    fileprivate static func addExceptionPort(
        _ exceptionPort: Mach.Exception, toPort port: Mach.PortWithExceptionPorts
    ) throws {
        let setExceptionPortsCall:
            @convention(c) (
                mach_port_name_t, exception_mask_t, mach_port_name_t,
                exception_behavior_t, thread_state_flavor_t
            ) -> kern_return_t =
                switch port {
                case is Mach.Task: task_set_exception_ports
                case is Mach.Thread: thread_set_exception_ports
                case is Mach.Host: host_set_exception_ports
                default:
                    fatalError("Unsupported port type.")
                }
        try Mach.call(
            setExceptionPortsCall(
                port.name, exceptionPort.mask.rawValue, exceptionPort.name,
                exceptionPort.behavior.rawValue, exceptionPort.threadStateFlavor.rawValue
            )
        )
    }

    /// Adds an exception port to the task.
    public func addExceptionPort(toTask task: Mach.Task) throws {
        try Self.addExceptionPort(self, toPort: task)
    }

    /// Adds an exception port to the thread.
    public func addExceptionPort(toThread thread: Mach.Thread) throws {
        try Self.addExceptionPort(self, toPort: thread)
    }

    /// Adds an exception port to the host.
    public func addExceptionPort(toHost host: Mach.Host) throws {
        try Self.addExceptionPort(self, toPort: host)
    }
}

extension Mach {
    /// A port representing a kernel object that can have exception ports.
    public protocol PortWithExceptionPorts: Mach.Port {

        /// Returns the exception ports for the port's kernel object for the types specified by the mask.
        func exceptionPorts(mask: Mach.ExceptionMask) throws -> [Mach.Exception]

        /// All the exception ports for the port's kernel object.
        var exceptionPorts: [Mach.Exception] { get throws }

        /// Adds an exception port to the port's kernel object.
        func addExceptionPort(_ exceptionPort: Mach.Exception) throws
    }
}

extension Mach.Task: Mach.PortWithExceptionPorts {
    /// Gets the exception ports for the task that catch the exception types specified by the mask.
    public func exceptionPorts(mask: Mach.ExceptionMask) throws -> [Mach.Exception] {
        try Mach.Exception.exceptionPorts(forPort: self, mask: mask)
    }

    /// All the exception ports for the task.
    public var exceptionPorts: [Mach.Exception] {
        get throws { try exceptionPorts(mask: .all) }
    }

    /// Adds an exception port to the task.
    public func addExceptionPort(_ exceptionPort: Mach.Exception) throws {
        try exceptionPort.addExceptionPort(toTask: self)
    }
}

extension Mach.Thread: Mach.PortWithExceptionPorts {
    /// Gets the exception ports for the thread that catch the exception types specified by the mask.
    public func exceptionPorts(mask: Mach.ExceptionMask) throws -> [Mach.Exception] {
        try Mach.Exception.exceptionPorts(forPort: self, mask: mask)
    }

    /// All the exception ports for the thread.
    public var exceptionPorts: [Mach.Exception] {
        get throws { try exceptionPorts(mask: .all) }
    }

    /// Adds an exception port to the thread.
    public func addExceptionPort(_ exceptionPort: Mach.Exception) throws {
        try exceptionPort.addExceptionPort(toThread: self)
    }
}

extension Mach.Host: Mach.PortWithExceptionPorts {
    /// Gets the exception ports for the host that catch the exception types specified by the mask.
    public func exceptionPorts(mask: Mach.ExceptionMask) throws -> [Mach.Exception] {
        try Mach.Exception.exceptionPorts(forPort: self, mask: mask)
    }

    /// All the exception ports for the host.
    public var exceptionPorts: [Mach.Exception] {
        get throws { try exceptionPorts(mask: .all) }
    }

    /// Adds an exception port to the host.
    public func addExceptionPort(_ exceptionPort: Mach.Exception) throws {
        try exceptionPort.addExceptionPort(toHost: self)
    }
}

extension Mach.Task {
    /// Registers a hardened exception handler for the task.
    @available(macOS, introduced: 15.0)
    public func registerHardenedExceptionHandler(
        _ exceptionPort: Mach.Exception, signedPCKey: UInt32
    ) throws {
        try Mach.call(
            task_register_hardened_exception_handler(
                self.name, signedPCKey,
                exceptionPort.mask.rawValue,
                exceptionPort.behavior.rawValue,
                exceptionPort.threadStateFlavor.rawValue,
                exceptionPort.name
            )
        )
    }
}
