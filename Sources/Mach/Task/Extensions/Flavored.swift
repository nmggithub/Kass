import Darwin.Mach

extension Mach.Task {
    /// A flavor of task (port).
    public enum Flavor: mach_task_flavor_t {
        /// A task control port.
        case control = 0

        /// A task read port.
        case read = 1

        /// A task inspect port.
        case inspect = 2

        /// A task name port.
        case name = 3
    }

}

extension Mach {
    /// A task (port) with a flavor.
    public protocol FlavoredTask: Mach.Task {
        /// The flavor of the task port.
        var flavor: Mach.Task.Flavor { get }
    }
    /// A task's control port.
    public class TaskControl: Mach.Task, Mach.FlavoredTask {
        public let flavor: Mach.Task.Flavor = .control

        /// A nil task control port.
        override public class var Nil: Self {
            Self(named: mach_port_name_t(TASK_NULL))
        }
    }

    /// A task's read port.
    public class TaskRead: Mach.Task, Mach.FlavoredTask {
        public let flavor: Mach.Task.Flavor = .read

        /// A nil task read port.
        override public class var Nil: Self {
            Self(named: mach_port_name_t(TASK_READ_NULL))
        }
    }

    /// A task's inspect port.
    public class TaskInspect: Mach.Task, Mach.FlavoredTask {
        public let flavor: Mach.Task.Flavor = .inspect

        /// A nil task inspect port.
        override public class var Nil: Self {
            Self(named: mach_port_name_t(TASK_INSPECT_NULL))
        }
    }

    /// A task's name port.
    public class TaskName: Mach.Task, Mach.FlavoredTask {
        public let flavor: Mach.Task.Flavor = .name

        /// A nil task name port.
        override public class var Nil: Self {
            Self(named: mach_port_name_t(TASK_NAME_NULL))
        }
    }
}
