import Darwin.Mach
import MachTask
import MachThread

extension Mach.Host {
    /// A set of processors in a host.
    public class ProcessorSet: Mach.Port {
        /// The tasks in the processor set.
        public var tasks: [Mach.Task] {
            get throws {
                var taskList: task_array_t?
                var taskCount = mach_msg_type_number_t.max
                try Mach.Syscall(processor_set_tasks(self.name, &taskList, &taskCount))
                return (0..<Int(taskCount)).map {
                    Mach.Task(named: taskList![$0])
                }
            }
        }
        /// Get the flavored tasks in the processor set.
        /// - Parameter flavor: The flavor of the tasks.
        /// - Throws: If the tasks cannot be retrieved.
        /// - Returns: The flavored tasks.
        public func flavoredTasks(_ flavor: Mach.Task.Flavor) throws -> [Mach.Task] {
            var taskList: task_array_t?
            var taskCount = mach_msg_type_number_t.max
            try Mach.Syscall(
                processor_set_tasks_with_flavor(self.name, flavor.rawValue, &taskList, &taskCount)
            )
            return (0..<Int(taskCount)).map {
                Mach.Task(named: taskList![$0])
            }
        }
        /// The threads in the processor set.
        public var threads: [Mach.Thread] {
            get throws {
                var threadList: thread_array_t?
                var threadCount = mach_msg_type_number_t.max
                try Mach.Syscall(processor_set_threads(self.name, &threadList, &threadCount))
                return (0..<Int(threadCount)).map {
                    Mach.Thread(named: threadList![$0])
                }
            }
        }
    }
}
