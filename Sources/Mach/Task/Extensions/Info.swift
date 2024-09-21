import Darwin.Mach

extension Mach.Task {
    /// A type of task info.
    public enum Info: task_flavor_t {
        case absoluteTime = 1
        case events = 2
        case threadTimes = 3
        case basic32 = 4
        case basic64 = 5
        case basic2_32 = 6
        case kernelMemory = 7
        @available(
            *, deprecated,
            message: "This task info type is listed as \"obsolete\" in the kernel."
        ) case schedTimeshare = 10
        @available(
            *, deprecated,
            message: "This task info type is listed as \"obsolete\" in the kernel."
        ) case rr = 11
        case securityToken = 13
        @available(
            *, deprecated,
            message: "This task info type is listed as \"obsolete\" in the kernel."
        ) case fifo = 14
        case auditToken = 15
        case affinityTag = 16
        case dyld = 17
        case basic64_2 = 18
        case extmod = 19
        case basic = 20
        case power = 21
        case vm = 22
        case vmPurgeable = 23
        case traceMemory = 24
        case waitState = 25
        case powerV2 = 26
        case purgeableAccount = 27
        case flags = 28
        // debug only flavors
        case debugInternal = 29
        case suspendStats = 30
        case suspendSources = 31
    }

    /// Gets the task's info.
    /// - Parameters:
    ///   - info: The info to get.
    ///   - type: The type to load the info as.
    /// - Throws: An error if the info cannot be retrieved.
    public func getInfo<DataType: BitwiseCopyable>(
        _ info: Info, as type: DataType.Type
    ) throws -> DataType {
        try Mach.callWithCountInOut(type: type) {
            (array: task_info_t, count) in
            task_info(self.name, info.rawValue, array, &count)
        }
    }

    /// Sets the task's info.
    /// - Parameters:
    ///   - info: The info to set.
    ///   - value: The value to set the info to.
    /// - Throws: An error if the info cannot be set.
    public func setInfo<DataType: BitwiseCopyable>(
        _ info: Info, to value: DataType
    ) throws {
        try Mach.callWithCountIn(value: value) {
            (array: task_info_t, count) in
            task_set_info(self.name, info.rawValue, array, count)
        }
    }
}
