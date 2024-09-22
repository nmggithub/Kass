import Darwin.Mach

extension Mach.TaskInspect {
    /// A type of task inspect info.
    public enum Info: task_inspect_flavor_t {
        case basicCounts = 1
    }

    /// Gets the task inspect port's info.
    /// - Parameters:
    ///   - info: The info to get.
    ///   - type: The type to load the info as.
    /// - Throws: An error if the info cannot be retrieved.
    /// - Returns: The info.
    public func getInfo<DataType: BitwiseCopyable>(
        _ info: Info, as type: DataType.Type
    ) throws -> DataType {
        try Mach.callWithCountInOut(type: type) {
            (array: task_inspect_info_t, count) in
            task_inspect(self.name, info.rawValue, array, &count)
        }
    }
}
