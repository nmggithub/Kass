@preconcurrency import Darwin.Mach

extension Mach {
    /// A task.
    open class Task: Mach.Port {
        /// The current task.
        public static var current: TaskControl { TaskControl(named: mach_task_self_) }

        /// If the task is the current task.
        public var isSelf: Bool { mach_task_is_self(self.name) != 0 ? true : false }

        /// The ports (really, port names) in the task's name space.
        public var ports: [Mach.Port] {
            get throws {
                var namesCount = mach_msg_type_number_t.max
                var names: mach_port_name_array_t? = mach_port_name_array_t.allocate(
                    capacity: Int(namesCount)
                )
                // The types array is not used, but it is required by `mach_port_names`.
                var typesCount = mach_msg_type_number_t.max
                var types: mach_port_type_array_t? = mach_port_type_array_t.allocate(
                    capacity: Int(typesCount)
                )
                try Mach.call(
                    mach_port_names(self.name, &names, &namesCount, &types, &typesCount)
                )
                return (0..<Int(namesCount)).map {
                    let port = Mach.Port(named: names![$0], in: self)
                    return port
                }
            }
        }
        /// Sets the physical footprint limit for the task.
        /// - Returns: The old limit.
        public func setPhysicalFootprintLimit(_ limit: Int32) throws -> Int32 {
            var oldLimit: Int32 = 0
            try Mach.call(task_set_phys_footprint_limit(self.name, limit, &oldLimit))
            return oldLimit
        }
    }
}
