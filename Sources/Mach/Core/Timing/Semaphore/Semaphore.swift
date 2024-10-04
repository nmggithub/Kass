import Darwin.Mach

extension Mach {
    /// A synchronization policy for a semaphore.
    public struct SemaphorePolicy: Mach.OptionEnum, Mach.NamedOptionEnum {
        /// The name of the policy option, if it can be determined.
        public var name: String?

        /// Represents a raw policy option with an optional name.
        public init(name: String?, rawValue: sync_policy_t) {
            self.name = name
            self.rawValue = rawValue
        }

        /// The raw value of the policy option.
        public let rawValue: sync_policy_t

        /// All known synchronization policies.
        public static let allCases: [Self] = [.fifo, .lifo]

        /// First-in-first-out policy.
        public static let fifo = Self(name: "fifo", rawValue: SYNC_POLICY_FIFO)

        /// Last-in-first-out policy.
        public static let lifo = Self(name: "lifo", rawValue: SYNC_POLICY_LIFO)
    }

}

extension Mach {
    /// A semaphore.
    public class Semaphore: Mach.Port {
        /// The task that owns the semaphore.
        public let semaphoreOwningTask: Mach.Task

        /// The synchronization policy of the semaphore.
        public let policy: Mach.SemaphorePolicy

        /// Creates a new semaphore in the given task.
        public init(inTask task: Mach.Task, policy: Mach.SemaphorePolicy, value: Int32) throws {
            self.semaphoreOwningTask = task  // store the owning task so we use it to destroy the semaphore
            self.policy = policy  // store the policy so we can refer to it later
            var semaphore = semaphore_t()
            try Mach.call(semaphore_create(task.name, &semaphore, policy.rawValue, value))
            super.init(named: semaphore)
        }

        @available(*, unavailable, message: "Use `init(in:policy:value:)` instead")
        required init(named name: mach_port_name_t, inNameSpaceOf task: Task = .current) {
            self.semaphoreOwningTask = Mach.Task.current
            self.policy = .init(rawValue: -1)
            super.init(named: name, inNameSpaceOf: task)
        }
        /// Destroys the semaphore.
        public override func destroy() throws {
            try Mach.call(semaphore_destroy(semaphoreOwningTask.name, name))
        }

        /// Signals the semaphore.
        public func signal(all: Bool = false) throws {
            try Mach.call(all ? semaphore_signal_all(name) : semaphore_signal(name))
        }

        /// Signals a specific thread waiting on the semaphore.
        public func signal(_ thread: Mach.Thread) throws {
            try Mach.call(semaphore_signal_thread(name, thread.name))
        }

        /// Waits for the semaphore.
        public func wait(timeout: mach_timespec_t? = nil) throws {
            try Mach.call(
                timeout != nil
                    ? semaphore_timedwait(name, timeout!)
                    : semaphore_wait(name)
            )
        }

        /// Atomically waits for one semaphore and signals another.
        public static func wait(
            forSemaphore waitSemaphore: Semaphore, thenSignalSemaphore signalSemaphore: Semaphore,
            timeout: mach_timespec_t? = nil
        ) throws {
            try Mach.call(
                timeout != nil
                    ? semaphore_timedwait_signal(waitSemaphore.name, signalSemaphore.name, timeout!)
                    : semaphore_wait_signal(waitSemaphore.name, signalSemaphore.name)
            )
        }
    }
}
