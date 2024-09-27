import Darwin.Mach

extension Mach {
    /// A flavor of task (port).
    public enum TaskFlavor: mach_task_flavor_t {
        /// A task control port.
        case control = 0

        /// A task read port.
        case read = 1

        /// A task inspect port.
        case inspect = 2

        /// A task name port.
        case name = 3
    }
    /// A task (port) with a flavor.
    public protocol TaskFlavored: Mach.Task {
        /// The flavor of the task port.
        var flavor: Mach.TaskFlavor { get }
    }
}

extension Mach {
    /// A task's control port.
    public class TaskControl: Mach.Task, Mach.TaskFlavored {
        /// The ``Mach/TaskFlavor/control`` flavor.
        public let flavor: Mach.TaskFlavor = .control

        /// A nil task control port.
        override public class var Nil: Self {
            Self(named: mach_port_name_t(TASK_NULL))
        }
    }

    /// A task's read port.
    public class TaskRead: Mach.Task, Mach.TaskFlavored {
        /// The ``Mach/TaskFlavor/read`` flavor.
        public let flavor: Mach.TaskFlavor = .read

        /// A nil task read port.
        override public class var Nil: Self {
            Self(named: mach_port_name_t(TASK_READ_NULL))
        }
    }

    /// A task's inspect port.
    public class TaskInspect: Mach.Task, Mach.TaskFlavored {
        /// The ``Mach/TaskFlavor/inspect`` flavor.
        public let flavor: Mach.TaskFlavor = .inspect

        /// A nil task inspect port.
        override public class var Nil: Self {
            Self(named: mach_port_name_t(TASK_INSPECT_NULL))
        }
    }

    /// A task's name port.
    public class TaskName: Mach.Task, Mach.TaskFlavored {
        /// The ``Mach/TaskFlavor/name`` flavor.
        public let flavor: Mach.TaskFlavor = .name

        /// A nil task name port.
        override public class var Nil: Self {
            Self(named: mach_port_name_t(TASK_NAME_NULL))
        }
    }
}
