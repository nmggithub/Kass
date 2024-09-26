import Darwin.Mach

extension Mach.Thread {
    public struct Switching: Namespace {
        /// A thread switching option.
        public enum Option: Int32 {
            case none = 0
            case depress = 1
            case wait = 2
            case dispatchContention = 4
            case oslockDepress = 8
            case oslockWait = 16
        }
        /// Switches to a different thread.
        /// - Parameters:
        ///   - thread: The thread to switch to.
        ///   - option: The option to use.
        ///   - timeout: The timeout to use.
        /// - Throws: An error if the operation fails.
        public static func `switch`(
            to thread: Mach.Thread, option: Option = .none,
            timeout: mach_msg_timeout_t
        ) throws {
            try Mach.call(thread_switch(thread.name, option.rawValue, timeout))
        }

        /// Aborts the depression of a thread.
        /// - Parameter thread: The thread to abort the depression of.
        /// - Throws: An error if the operation fails.
        public static func abortDepression(of thread: Mach.Thread) throws {
            try Mach.call(thread_depress_abort(thread.name))
        }
    }
}
