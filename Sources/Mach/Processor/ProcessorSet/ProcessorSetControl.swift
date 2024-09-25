import Darwin.Mach
import MachTask
import MachThread

extension Mach {
    public class ProcessorSetControl: Mach.Port {
        /// The tasks in the processor set.
        public var tasks: [Mach.TaskControl] {
            get throws {
                var taskList: task_array_t?
                var taskCount = mach_msg_type_number_t.max
                try Mach.call(processor_set_tasks(self.name, &taskList, &taskCount))
                return (0..<Int(taskCount)).map {
                    Mach.TaskControl(named: taskList![$0])
                }
            }
        }

        /// Gets the flavored tasks in the processor set.
        public func flavoredTasks(_ flavor: Mach.Task.Flavor) throws -> [Mach.Task.Flavored] {
            var taskList: task_array_t?
            var taskCount = mach_msg_type_number_t.max
            try Mach.call(
                processor_set_tasks_with_flavor(self.name, flavor.rawValue, &taskList, &taskCount)
            )
            return (0..<Int(taskCount)).map {
                return switch flavor {
                case .control: Mach.TaskControl(named: taskList![$0])
                case .read: Mach.TaskRead(named: taskList![$0])
                case .inspect: Mach.TaskInspect(named: taskList![$0])
                case .name: Mach.TaskName(named: taskList![$0])
                }
            }
        }

        /// The threads in the processor set.
        public var threads: [Mach.Thread] {
            get throws {
                var threadList: thread_array_t?
                var threadCount = mach_msg_type_number_t.max
                try Mach.call(processor_set_threads(self.name, &threadList, &threadCount))
                return (0..<Int(threadCount)).map {
                    Mach.Thread(named: threadList![$0])
                }
            }
        }
    }
}
