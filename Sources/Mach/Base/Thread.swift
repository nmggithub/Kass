import Darwin.Mach

extension Mach {
    /// A thread.
    public class Thread: Mach.Port {
        /// The current thread.
        public static var current: Self { Self(named: mach_thread_self()) }

        /// Creates a new thread in a given task.
        /// - Warning: The initial execution state of the thread is undefined.
        public convenience init(in task: Task) throws {
            var thread = thread_act_t()
            try Mach.call(thread_create(task.name, &thread))
            self.init(named: thread)
        }

        /// Suspends the thread.
        public func suspend() throws { try Mach.call(thread_suspend(self.name)) }

        /// Resumes the thread.
        public func resume() throws { try Mach.call(thread_resume(self.name)) }

        /// Aborts the thread.
        /// - Parameter safely: Whether to abort the thread safely.
        public func abort(safely: Bool = false) throws {
            try Mach.call(safely ? thread_abort_safely(self.name) : thread_abort(self.name))
        }

        /// Wires a thread.
        public func wire(host: Mach.Host = .current) throws {
            try Mach.call(thread_wire(host.name, self.name, 1))
        }
        /// Unwires a thread.
        public func unwire(host: Mach.Host = .current) throws {
            try Mach.call(thread_wire(host.name, self.name, 0))
        }

    }
}

extension Mach.Thread {
    /// A thread switching option.
    public enum SwitchingOption: Int32 {
        case none = 0
        case depress = 1
        case wait = 2
        case dispatchContention = 4
        case oslockDepress = 8
        case oslockWait = 16
    }

    /// Switches to a thread.
    public static func `switch`(
        to thread: Mach.Thread, option: SwitchingOption = .none,
        timeout: mach_msg_timeout_t
    ) throws {
        try Mach.call(thread_switch(thread.name, option.rawValue, timeout))
    }

    /// Aborts the depression of the thread.
    public func abortDepression() throws {
        try Mach.call(thread_depress_abort(self.name))
    }
}
