import Darwin.Mach

extension Mach {
    /// A task's identity token.
    public class TaskIdentityToken: Mach.Port {
        /// Gets the identity token for a task.
        public convenience init(for task: Mach.Task) throws {
            var token = mach_port_name_t()
            try Mach.call(task_create_identity_token(task.name, &token))
            self.init(named: token)
        }

        /// Uses the identity token to get the task port of a given flavor.
        /// - Important: The result should be cast to the appropriate subclass.
        public func taskPort(_ flavor: Mach.TaskFlavor) throws -> Mach.Task & Mach.TaskFlavored {
            var taskPortName = mach_port_name_t()
            try Mach.call(
                task_identity_token_get_task_port(self.name, flavor.rawValue, &taskPortName)
            )
            switch flavor {
            case .control:
                return Mach.TaskControl(named: taskPortName)
            case .read:
                return Mach.TaskRead(named: taskPortName)
            case .inspect:
                return Mach.TaskInspect(named: taskPortName)
            case .name:
                return Mach.TaskName(named: taskPortName)
            default:
                fatalError("Unknown task flavor: \(flavor.rawValue)")
            }
        }

        /// The control port for the task the identity token is for.
        public var controlPort: Mach.TaskControl {
            get throws { try taskPort(.control) as! Mach.TaskControl }
        }

        /// The read port for the task the identity token is for.
        public var readPort: Mach.TaskRead {
            get throws { try taskPort(.read) as! Mach.TaskRead }
        }

        /// The inspect port for the task the identity token is for.
        public var inspectPort: Mach.TaskInspect {
            get throws { try taskPort(.inspect) as! Mach.TaskInspect }
        }

        /// The name port for the task the identity token is for.
        public var namePort: Mach.TaskName {
            get throws { try taskPort(.name) as! Mach.TaskName }
        }
    }
}

extension Mach.Task {
    /// The task's identity token.
    public var identityToken: Mach.TaskIdentityToken {
        get throws { try Mach.TaskIdentityToken(for: self) }
    }
}
