import Darwin.Mach

extension Mach {
    /// A type of task inspect info.
    public enum TaskInspectInfoFlavor: task_inspect_flavor_t {
        /// Basic CPU instruction and cycle counts.
        case basicCounts = 1
    }
}

extension Mach.Task {
    /// Gets the task's inspect info.
    public func inspect<DataType: BitwiseCopyable>(
        _ info: Mach.TaskInspectInfoFlavor, as type: DataType.Type
    ) throws -> DataType {
        try Mach.callWithCountInOut(type: type) {
            (array: task_inspect_info_t, count) in
            task_inspect(self.name, info.rawValue, array, &count)
        }
    }
}

extension Mach.Task {
    /// Basic CPU instruction and cycle counts.
    public var basicCounts: task_inspect_basic_counts {
        get throws { try inspect(.basicCounts, as: task_inspect_basic_counts.self) }
    }
}

extension Mach.TaskInspectInfoFlavor {
    /// Gets the task's inspect info.
    public func inspect<DataType: BitwiseCopyable>(
        as type: DataType.Type = DataType.self, for task: Mach.Task = .current
    ) throws -> DataType {
        try task.inspect(self, as: type)
    }
}
