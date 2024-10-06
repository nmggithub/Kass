import Darwin.Mach
import KassHelpers

extension Mach {
    /// A thread in a task.
    public class Thread: Mach.Port {
        /// The current thread.
        public static var current: Mach.ThreadControl {
            Mach.ThreadControl(named: mach_thread_self())
        }

        /// Creates a new thread in a given task.
        /// - Warning: The initial execution state of the thread is undefined. Use ``Mach/Task/setDefaultThreadState(_:to:)`` to set initial state.
        public convenience init(inTask task: Task) throws {
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

        /// Terminates the thread.
        public func terminate() throws { try Mach.call(thread_terminate(self.name)) }

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
    public struct ThreadSwitchOption: KassHelpers.OptionEnum {
        public let rawValue: Int32
        public init(rawValue: Int32) { self.rawValue = rawValue }
        public static let none = Self(rawValue: SWITCH_OPTION_NONE)
        public static let depress = Self(rawValue: SWITCH_OPTION_DEPRESS)
        public static let wait = Self(rawValue: SWITCH_OPTION_WAIT)
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
    /// - Note: A thread may be in a depressed state due to a thread switching call.
    public func abortDepression() throws {
        try Mach.call(thread_depress_abort(self.name))
    }
}
