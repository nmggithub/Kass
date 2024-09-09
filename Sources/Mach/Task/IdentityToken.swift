import Darwin.Mach

extension Mach.Task {
    /// A task's identity token.
    public class IdentityToken: Mach.Port {
        /// Get the identity token for a task.
        /// - Parameter task: The task to get the identity token for.
        public convenience init(for task: Mach.Task) throws {
            var token = mach_port_name_t()
            try Mach.Syscall(task_create_identity_token(task.name, &token))
            self.init(named: token)
        }
        /// Use the identity token to get the task port for a given flavor.
        /// - Parameter flavor: The flavor of the task port to get.
        /// - Returns: The task port.
        public func taskPort(flavor: Flavor) throws -> Mach.Task & Flavored {
            var taskPortName = mach_port_name_t()
            try Mach.Syscall(
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
    }
}
