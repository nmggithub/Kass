import Darwin.Mach

extension Mach {
    /// A thread.
    public class Thread: Mach.Port {
        /// The current thread.
        public static var current: Mach.ThreadControl {
            Mach.ThreadControl(named: mach_thread_self())
        }

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
        public func abort(safely: Bool = true) throws {
            try Mach.call(safely ? thread_abort_safely(self.name) : thread_abort(self.name))
        }

        /// Wires a thread.
        public func wire(in host: Mach.Host = .current) throws {
            try Mach.call(thread_wire(host.name, self.name, 1))
        }
        /// Unwires a thread.
        public func unwire(in host: Mach.Host = .current) throws {
            try Mach.call(thread_wire(host.name, self.name, 0))
        }

    }
}

extension Mach {
    /// A thread switching option.
    public enum ThreadSwitchOption: Int32 {
        case none = 0
        case depress = 1
        case wait = 2
        case dispatchContention = 3
        case oslockDepress = 4
        case oslockWait = 5
    }
}

extension Mach.Thread {
    /// Switches to a thread.
    public static func `switch`(
        to thread: Mach.Thread, option: Mach.ThreadSwitchOption = .none,
        timeout: mach_msg_timeout_t
    ) throws {
        try Mach.call(thread_switch(thread.name, option.rawValue, timeout))
    }

    /// Aborts the depression of the thread.
    public func abortDepression() throws {
        try Mach.call(thread_depress_abort(self.name))
    }
}
