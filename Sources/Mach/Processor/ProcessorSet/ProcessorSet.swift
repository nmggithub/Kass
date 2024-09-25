import Darwin.Mach
import MachTask
import MachThread

extension Mach.Host {
    /// A set of processors in a host.
    public class ProcessorSet: Mach.Port {
        /// Gets the default processor set for a host.
        /// - Parameter host: The host to get the default processor set for.
        /// - Throws: If the default processor set cannot be retrieved.
        /// - Returns: The default processor set for the host.
        public static func `default`(in host: Mach.Host = .current) throws -> ProcessorSet {
            var name = processor_set_name_t()
            try Mach.call(processor_set_default(host.name, &name))
            return ProcessorSet(named: name)
        }
        /// The tasks in the processor set.
        public var tasks: [Mach.Task] {
            get throws {
                var taskList: task_array_t?
                var taskCount = mach_msg_type_number_t.max
                try Mach.call(processor_set_tasks(self.name, &taskList, &taskCount))
                return (0..<Int(taskCount)).map {
                    Mach.Task(named: taskList![$0])
                }
            }
        }
        /// Gets the flavored tasks in the processor set.
        /// - Parameter flavor: The flavor of the tasks.
        /// - Throws: If the tasks cannot be retrieved.
        /// - Returns: The flavored tasks.
        public func flavoredTasks(_ flavor: Mach.Task.Flavor) throws -> [Mach.Task] {
            var taskList: task_array_t?
            var taskCount = mach_msg_type_number_t.max
            try Mach.call(
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
                try Mach.call(processor_set_threads(self.name, &threadList, &threadCount))
                return (0..<Int(threadCount)).map {
                    Mach.Thread(named: threadList![$0])
                }
            }
        }
        /// Whether the processor set is a processor set control port.
        public var isControl: Bool {
            get throws {
                let kernelObject = try Mach.KernelObject(underlying: self)
                switch kernelObject.type {
                case .psetName: return false
                case .pset: return true
                default: fatalError("Processor set is somehow not a processor set")
                }
            }
        }
    }
}
