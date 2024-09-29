import Darwin.Mach

/// Adds properties to make the `task_role` enum more Swift-friendly.
extension task_inspect_flavor {
    /// The basic CPU instruction and cycle counts.
    public static let basicCounts = TASK_INSPECT_BASIC_COUNTS
}

extension Mach.Task {
    /// Gets the task's inspect info.
    public func inspect<DataType: BitwiseCopyable>(
        _ info: task_inspect_flavor, as type: DataType.Type
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

extension task_inspect_flavor {
    /// Gets the task's inspect info.
    public func inspect<DataType: BitwiseCopyable>(
        as type: DataType.Type = DataType.self, for task: Mach.Task = .current
    ) throws -> DataType {
        try task.inspect(self, as: type)
    }
}
