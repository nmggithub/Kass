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
    }
    /// A task's read port.
    public class ReadPort: Mach.Task, Flavored {
        public let flavor: Mach.Task.Flavor = .read
        /// A nil task read port.
        override public class var Nil: Self {
            Self(named: mach_port_name_t(TASK_READ_NULL))
        }
    }
    /// A task's inspect port.
    public class InspectPort: Mach.Task, Flavored {
        public let flavor: Mach.Task.Flavor = .inspect
        /// A nil task inspect port.
        override public class var Nil: Self {
            Self(named: mach_port_name_t(TASK_INSPECT_NULL))
        }
    }
    /// A task's name port.
    public class NamePort: Mach.Task, Flavored {
        public let flavor: Mach.Task.Flavor = .name
        /// A nil task name port.
        override public class var Nil: Self {
            Self(named: mach_port_name_t(TASK_NAME_NULL))
        }
    }
}
