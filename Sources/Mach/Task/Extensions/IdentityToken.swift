import Darwin.Mach

extension Mach.Task {
    public var identityToken: IdentityToken { get throws { try IdentityToken(for: self) } }
    /// A task's identity token.
    public class IdentityToken: Mach.Port {
        /// Get the identity token for a task.
        /// - Parameter task: The task to get the identity token for.
        public convenience init(for task: Mach.Task) throws {
            var token = mach_port_name_t()
            try Mach.call(task_create_identity_token(task.name, &token))
            self.init(named: token)
        }
        /// Use the identity token to get the task port for a given flavor.
        /// - Parameter flavor: The flavor of the task port to get.
        /// - Returns: The task port.
        /// - Warning: You must cast the returned task port to the correct subclass.
        public func taskPort(_ flavor: Flavor) throws -> Mach.Task & Flavored {
            var taskPortName = mach_port_name_t()
            try Mach.call(
                task_identity_token_get_task_port(self.name, flavor.rawValue, &taskPortName)
            )
            switch flavor {
            case .control:
                return Mach.Task.ControlPort(named: taskPortName)
            case .read:
                return Mach.Task.ReadPort(named: taskPortName)
            case .inspect:
                return Mach.Task.InspectPort(named: taskPortName)
            case .name:
                return Mach.Task.NamePort(named: taskPortName)
            }
        }

        /// The control port of the task the identity token is for.
        public var taskControlPort: ControlPort {
            get throws { try taskPort(.control) as! ControlPort }
        }
        /// The read port of the task the identity token is for.
        public var taskReadPort: ReadPort {
            get throws { try taskPort(.read) as! ReadPort }
        }
        /// The inspect port of the task the identity token is for.
        public var taskInspectPort: InspectPort {
            get throws { try taskPort(.inspect) as! InspectPort }
        }
        /// The name port of the task the identity token is for.
        public var taskNamePort: NamePort {
            get throws { try taskPort(.name) as! NamePort }
        }
    }
}
