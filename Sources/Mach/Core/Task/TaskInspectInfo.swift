import Darwin.Mach

/// Adds properties to make the `task_inspect_flavor` enum more Swift-friendly.
extension task_inspect_flavor: Mach.OptionEnum, @unchecked @retroactive Sendable {
    /// The basic CPU instruction and cycle counts.
    public static let basicCounts = TASK_INSPECT_BASIC_COUNTS
}

extension Mach {
    /// A task inspect info manager.
    public struct TaskInspectInfoManager: FlavoredDataGetter {
        /// The task port.
        internal let port: Task

        /// The task.
        internal var task: Task { self.port }

        /// Creates a task inspect info manager.
        public init(task: Task) { self.port = task }

        /// Gets the task's inspect info.
        public func get<DataType>(
            _ flavor: task_inspect_flavor, as type: DataType.Type = DataType.self
        ) throws
            -> DataType where DataType: BitwiseCopyable
        {
            try Mach.callWithCountInOut(type: type) {
                (array: task_inspect_info_t, count) in
                task_inspect(self.task.name, flavor.rawValue, array, &count)
            }
        }
    }
}

extension Mach.Task {
    /// A task inspect info manager.
    public var inspectInfo: Mach.TaskInspectInfoManager { .init(task: self) }
}

extension Mach.TaskInspectInfoManager {
    /// Basic CPU instruction and cycle counts.
    public var basicCounts: task_inspect_basic_counts {
        get throws { try self.get(.basicCounts) }
    }
}
