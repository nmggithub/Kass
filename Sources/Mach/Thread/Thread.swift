@preconcurrency import Darwin.Mach
import MachBase
import MachPort

extension Mach {
    public class Thread: Mach.Port {
        /// The current thread.
        public static let current = Thread(named: mach_thread_self())

        /// Create a new thread in a given task.
        /// - Parameter task: The task in which to create the thread.
        /// - Throws: An error if the thread could not be created.
        /// - Warning: The initial execution state of the thread is undefined.
        public convenience init(in task: Task) throws {
            var thread = thread_act_t()
            try Mach.Syscall(thread_create(task.name, &thread))
            self.init(named: thread)
        }
    }
}
