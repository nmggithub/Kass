@preconcurrency import Darwin.Mach
import Foundation

extension Mach {
    /// A task suspension token.
    public class TaskSuspensionToken: Mach.Port {}
}

extension Mach {
    /// A task (port).
    open class Task: Mach.Port {
        /// The current task.
        public static var current: TaskControl {
            TaskControl(named: mach_task_self_, inNameSpaceOf: mach_task_self_)
        }

        /// If the task is the current task.
        public var isSelf: Bool { mach_task_is_self(self.name) != 0 ? true : false }

        /// Suspends the task.
        public func suspend() throws { try Mach.call(task_suspend(self.name)) }

        /// Resumes the task.
        public func resume() throws { try Mach.call(task_resume(self.name)) }

        /// Terminates the task.
        public func terminate() throws { try Mach.call(task_terminate(self.name)) }

        /// Suspends the task and receive a suspension token.
        public func suspend2() throws -> Mach.TaskSuspensionToken {
            var token = task_suspension_token_t()
            try Mach.call(task_suspend2(self.name, &token))
            return Mach.TaskSuspensionToken(named: token)
        }

        /// Resumes the task with a suspension token.
        public func resume2(_ token: Mach.TaskSuspensionToken) throws {
            try Mach.call(task_resume2(token.name))
        }

        /// The threads in the task.
        public var threads: [Mach.Thread] {
            get throws {
                var threadList: thread_act_array_t?
                var threadCount = mach_msg_type_number_t.max
                try Mach.call(task_threads(self.name, &threadList, &threadCount))
                return (0..<Int(threadCount)).map {
                    Mach.Thread(named: threadList![$0])
                }
            }
        }

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
                    Mach.Port(named: names![$0], inNameSpaceOf: self)
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

extension Mach {
    /// A task's role.
    public enum TaskRole: Int32 {
        case reniced = -1
        case unspecified = 0
        case foreground = 1
        case background = 2
        case control = 3
        case graphicsServer = 4
        case throttle = 5
        case nonUI = 6
        case `default` = 7
        case darwinBackground = 8
    }
}

extension Mach.Task {
    /// The task's role.
    /// - Important: This property is `nil` if the task's role is not recognized.
    /// - Note: This is a wrapper around getting the ``categoryPolicy``.
    public var role: Mach.TaskRole? {
        get throws { try Mach.TaskRole(rawValue: self.categoryPolicy.role.rawValue) }
    }

    /// Sets the task's role.
    /// - Note: This is a wrapper around setting the ``categoryPolicy``.
    public func setRole(_ role: Mach.TaskRole) throws {
        try self.setPolicy(.category, to: task_category_policy(role: task_role(role.rawValue)))
    }
}

extension Mach.Task {
    /// The task's stashed ports.
    public var stashedPorts: [Mach.Port] {
        get throws {
            var portsCount = mach_msg_type_number_t.max
            var ports: mach_port_array_t? = mach_port_array_t.allocate(
                capacity: Int(portsCount)
            )
            try Mach.call(mach_ports_lookup(self.name, &ports, &portsCount))
            return (0..<Int(portsCount)).map {
                Mach.Port(named: ports![$0], inNameSpaceOf: self)
            }
        }
    }

    /// Sets the task's stashed ports.
    public func setStashedPorts(_ ports: [Mach.Port]) throws {
        let portsCount = mach_msg_type_number_t(ports.count)
        var portNames = ports.map(\.name)
        try Mach.call(mach_ports_register(self.name, &portNames, portsCount))
    }
}

extension Mach.Task {
    /// Gets the data of a kernelcache object.
    public func kernelcacheData<DataType>(
        of kcObject: Mach.Port, as type: DataType.Type
    ) throws -> DataType {
        let data = try self.kernelcacheData(of: kcObject)
        return data.withUnsafeBytes { buffer in
            buffer.load(as: DataType.self)
        }
    }

    /// Gets the data of a kernelcache object.
    public func kernelcacheData(of kcObject: Mach.Port) throws -> Data {
        var address = mach_vm_address_t()
        var size = mach_vm_size_t()
        try Mach.call(
            task_map_kcdata_object_64(self.name, kcObject.name, &address, &size)
        )
        guard let addressPointer = UnsafeRawPointer(bitPattern: Int(address)) else {
            fatalError("`task_map_kcdata_object_64` returned a null pointer.")
        }
        return Data(
            bytes: addressPointer,
            count: Int(size)
        )
    }
}