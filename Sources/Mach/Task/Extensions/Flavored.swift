import Darwin.Mach

extension Mach.Task {
    // A flavor of task (port).
    public enum Flavor: mach_task_flavor_t {
        case control = 0
        case read = 1
        case inspect = 2
        case name = 3
    }

    /// A task (port) with a flavor.
    public protocol Flavored: Mach.Task {
        var flavor: Mach.Task.Flavor { get }
    }
    /// A task's control port.
    public class ControlPort: Mach.Task, Flavored {
        public let flavor: Mach.Task.Flavor = .control
        /// A nil task control port.
        override public class var Nil: Self {
            Self(named: mach_port_name_t(TASK_NULL))
        }
        /// References a given task from its control port.
        /// - Parameter name: The name of the task's control port.
        /// - Warning: This will crash the program if the port named by `name` is not a task control port.
        public required init(named name: mach_port_name_t) {
            super.init(named: name)
            guard (try? Mach.KernelObject(underlying: self).type) == .taskControl else {
                fatalError(self.loggable("Not a task control port"))
            }
        }
    }
    /// A task's read port.
    public class ReadPort: Mach.Task, Flavored {
        public let flavor: Mach.Task.Flavor = .read
        /// A nil task read port.
        override public class var Nil: Self {
            Self(named: mach_port_name_t(TASK_READ_NULL))
        }
        /// References a given task from its read port.
        /// - Parameter name: The name of the task's read port.
        /// - Warning: This will crash the program if the port named by `name` is not a task read port.
        public required init(named name: mach_port_name_t) {
            super.init(named: name)
            guard (try? Mach.KernelObject(underlying: self).type) == .taskRead else {
                fatalError(self.loggable("Not a task read port"))
            }
        }
    }
    /// A task's inspect port.
    public class InspectPort: Mach.Task, Flavored {
        public let flavor: Mach.Task.Flavor = .inspect
        /// A nil task inspect port.
        override public class var Nil: Self {
            Self(named: mach_port_name_t(TASK_INSPECT_NULL))
        }
        /// References a given task from its inspect port.
        /// - Parameter name: The name of the task's inspect port.
        /// - Warning: This will crash the program if the port named by `name` is not a task inspect port.
        public required init(named name: mach_port_name_t) {
            super.init(named: name)
            guard (try? Mach.KernelObject(underlying: self).type) == .taskInspect else {
                fatalError(self.loggable("Not a task inspect port"))
            }
        }
    }
    /// A task's name port.
    public class NamePort: Mach.Task, Flavored {
        public let flavor: Mach.Task.Flavor = .name
        /// A nil task name port.
        override public class var Nil: Self {
            Self(named: mach_port_name_t(TASK_NAME_NULL))
        }
        /// References a given task from its name port.
        /// - Parameter name: The name of the task's name port.
        /// - Warning: This will crash the program if the port named by `name` is not a task name port.
        public required init(named name: mach_port_name_t) {
            super.init(named: name)
            guard (try? Mach.KernelObject(underlying: self).type) == .taskName else {
                fatalError(self.loggable("Not a task name port"))
            }
        }
    }
}
