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

        /// The PID of the task.
        public var pid: pid_t {
            get throws {
                var pid: pid_t = 0
                try Mach.call(pid_for_task(self.name, &pid))
                return pid
            }
        }

        /// Atomically gets the debug port for the task with the given PID.
        public static func debugPort<PortType: Mach.Port>(forPID pid: pid_t) throws -> PortType {
            var port: mach_port_name_t = 0
            try Mach.call(debug_control_port_for_pid(mach_task_self_, pid, &port))
            return PortType(named: port, inNameSpaceOf: .current)
        }

        /// If the task is the current task.
        @available(macOS 11.3, *)
        public var isCurrentTask: Bool { mach_task_is_self(self.name) != 0 ? true : false }

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
        public func resume2(token: Mach.TaskSuspensionToken) throws {
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

/// Adds properties to make the `task_role` enum more Swift-friendly.
extension task_role {
    public static let reniced = TASK_RENICED
    public static let unspecified = TASK_UNSPECIFIED
    public static let foreground = TASK_FOREGROUND_APPLICATION
    public static let background = TASK_BACKGROUND_APPLICATION
    public static let control = TASK_CONTROL_APPLICATION
    public static let graphicsServer = TASK_GRAPHICS_SERVER
    public static let throttle = TASK_THROTTLE_APPLICATION
    public static let nonUI = TASK_NONUI_APPLICATION
    public static let `default` = TASK_DEFAULT_APPLICATION
    public static let darwinBackground = TASK_DARWINBG_APPLICATION
}

extension Mach.Task {
    /// The task's role.
    /// - Important: This property is `nil` if the task's role is not recognized.
    /// - Note: This is a wrapper around getting the ``Mach/TaskPolicyManager/categoryPolicy``.
    public var role: task_role {
        get throws { try task_role(rawValue: self.policy.categoryPolicy.role.rawValue) }
    }

    /// Sets the task's role.
    /// - Note: This is a wrapper around setting the ``Mach/TaskPolicyManager/categoryPolicy``.
    public func setRole(to role: task_role) throws {
        try self.policy.setCategoryPolicy(to: task_category_policy(role: role))
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

    /// Stashes the given ports in the task.
    public func stashPorts(_ ports: [Mach.Port]) throws {
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

extension Mach.Task {
    /// Information about the task's IPC space (name space), split into three parts.
    private var ipcSpaceInfo: (ipc_info_space_t, [ipc_info_name_t], [ipc_info_tree_name_t]) {
        get throws {
            var info: ipc_info_space_t = ipc_info_space_t()
            var infoNameArray: ipc_info_name_array_t?
            var infoNameCount = mach_msg_type_number_t.max
            var infoTreeNameArray: ipc_info_tree_name_array_t?
            var infoTreeNameCount = mach_msg_type_number_t.max
            try Mach.call(
                mach_port_space_info(
                    self.name, &info,
                    &infoNameArray, &infoNameCount,
                    &infoTreeNameArray, &infoTreeNameCount
                )
            )
            return (
                info,
                infoNameArray != nil
                    ? Array(0..<Int(infoNameCount)).map { infoNameArray![$0] }
                    : [],
                infoTreeNameArray != nil
                    ? Array(0..<Int(infoTreeNameCount)).map { infoTreeNameArray![$0] }
                    : []
            )
        }
    }

    /// Information about the task's name space.
    public var nameSpaceInfo: ipc_info_space_t {
        get throws { try self.ipcSpaceInfo.0 }
    }

    /// The task's name space table.
    public var nameSpaceTable: [ipc_info_name_t] {
        get throws { try self.ipcSpaceInfo.1 }
    }

    /// The task's name space tree.
    /// - Note: This will likely be empty as the name space tree is not currently used.
    public var nameSpaceTree: [ipc_info_tree_name_t] {
        get throws { try self.ipcSpaceInfo.2 }
    }
}
