import Darwin.Mach
@_exported import MachCore

extension Mach {
    /// A semaphore.
    public class Semaphore: Mach.Port {
        /// A synchronization policy for a semaphore.
        public enum Policy: sync_policy_t {
            /// - Warning: This case should never be used.
            case unknown = -1
            case fifo = 0
            @available(*, deprecated)
            case fixedPriority = 1
            case lifo = 2
        }
        /// The task that owns the semaphore.
        public let semaphoreOwningTask: Mach.Task
        /// The synchronization policy of the semaphore.
        public let policy: Policy
        /// Creates a new semaphore in the given task.
        /// - Parameters:
        ///   - task: The task in which to create the semaphore.
        ///   - policy: The synchronization policy to use for the semaphore.
        ///   - value: The initial value of the semaphore.
        /// - Throws: An error if the semaphore could not be created.
        public init(in task: Mach.Task, policy: Policy, value: Int32) throws {
            self.semaphoreOwningTask = task  // store the owning task so we use it to destroy the semaphore
            self.policy = policy  // store the policy so we can refer to it later
            var semaphore = semaphore_t()
            try Mach.call(semaphore_create(task.name, &semaphore, policy.rawValue, value))
            super.init(named: semaphore)
        }
        @available(*, unavailable, message: "Use `init(in:policy:value:)` instead")
        required init(named name: mach_port_name_t, inNameSpaceOf task: Task = .current) {
            self.semaphoreOwningTask = Mach.Task.current
            self.policy = .unknown
            super.init(named: name, inNameSpaceOf: task)
        }
        /// Destroys the semaphore.
        /// - Throws: An error if the semaphore could not be destroyed.
        public override func destroy() throws {
            try Mach.call(semaphore_destroy(semaphoreOwningTask.name, name))
        }
        /// Signals the semaphore.
        /// - Parameter all: Whether to signal all threads waiting on the semaphore.
        /// - Throws: An error if the semaphore could not be signaled.
        public func signal(all: Bool = false) throws {
            try Mach.call(all ? semaphore_signal_all(name) : semaphore_signal(name))
        }

        /// Signals a specific thread waiting on the semaphore.
        /// - Parameter thread: The thread to signal.
        /// - Throws: An error if the thread could not be signaled.
        /// - Warning: If a null thread is specified, any thread waiting on the semaphore will be signaled.
        public func signal(_ thread: Mach.Thread) throws {
            try Mach.call(semaphore_signal_thread(name, thread.name))
        }

        /// Waits for the semaphore.
        /// - Parameter timeout: The timeout to wait for the semaphore.
        /// - Throws: An error if the semaphore could not be waited on.
        public func wait(timeout: mach_timespec_t? = nil) throws {
            try Mach.call(
                timeout != nil
                    ? semaphore_timedwait(name, timeout!)
                    : semaphore_wait(name)
            )
        }

        /// Atomically waits for one semaphore and signals another.
        /// - Parameters:
        ///   - waitSemaphore: The semaphore to wait for.
        ///   - signalSemaphore: The semaphore to signal.
        /// - Throws: An error if the semaphores could not be waited on and signaled.
        public static func wait(
            for waitSemaphore: Semaphore, thenSignal signalSemaphore: Semaphore,
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
