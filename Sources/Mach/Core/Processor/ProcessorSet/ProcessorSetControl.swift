import Darwin.Mach

extension Mach {
    /// A control port for a processor set.
    public class ProcessorSetControl: Mach.Port {
        /// The (control ports for the) tasks in the processor set.
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

        /// Gets the flavored task ports in the processor set.
        public func tasks(withFlavor flavor: Mach.TaskFlavor) throws -> [Mach.TaskFlavored] {
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
                default: fatalError("Unknown task flavor: \(flavor.rawValue)")
                }
            }
        }

        /// The control ports for the tasks in the processor set.
        /// - Note: This should be the same as ``tasks``.
        public var taskControlPorts: [Mach.TaskControl] {
            get throws { try self.tasks(withFlavor: .control) as! [Mach.TaskControl] }
        }

        /// The read ports for the tasks in the processor set.
        public var taskReadPorts: [Mach.TaskRead] {
            get throws { try self.tasks(withFlavor: .read) as! [Mach.TaskRead] }
        }

        /// The inspect ports for the tasks in the processor set.
        public var taskInspectPorts: [Mach.TaskInspect] {
            get throws { try self.tasks(withFlavor: .inspect) as! [Mach.TaskInspect] }
        }

        /// The name ports for the tasks in the processor set.
        public var taskNamePorts: [Mach.TaskName] {
            get throws { try self.tasks(withFlavor: .name) as! [Mach.TaskName] }
        }
    }
}

extension Mach.ProcessorSetControl {
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
