@preconcurrency import Darwin.Mach

/// A task (port).
typealias MachTask = Mach.Task

extension Mach {
    /// A task (port).
    open class Task: Mach.Port, Mach.Port.Deallocatable {
        /// The current task.
        public static var current: Self { Self(named: mach_task_self_) }
        /// If the task is the current task.
        public var isSelf: Bool { mach_task_is_self(self.name) != 0 ? true : false }
        /// The ports in the task's namespace.
        public var ports: [Mach.Port] {
            get throws {
                var namesCount = mach_msg_type_number_t.max
                var names: mach_port_name_array_t? = mach_port_name_array_t.allocate(
                    capacity: Int(namesCount)
                )
                // the types array is not used, but it is required by `mach_port_names`
                var typesCount = mach_msg_type_number_t.max
                var types: mach_port_type_array_t? = mach_port_type_array_t.allocate(
                    capacity: Int(typesCount)
                )
                try Mach.call(
                    mach_port_names(self.name, &names, &namesCount, &types, &typesCount)
                )
                return (0..<Int(namesCount)).map {
                    let port = Mach.Port(named: names![$0])
                    port.owningTask = self
                    return port
                }
            }
        }
    }
}
