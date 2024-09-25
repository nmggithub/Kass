import Darwin.Mach

extension Mach.Task {
    /// A type of task info.
    public enum Info: task_flavor_t {
        /// Basic information about the task.
        @available(macOS, deprecated: 10.8, message: "Use `basic` instead.")
        case basic32 = 4

        /// Like ``basic32``, but with the maximum resident size instead of the current size.
        @available(macOS, deprecated: 10.8, message: "Use `basic` instead.")
        case basic2_32 = 6

        /// Basic information about the task (64-bit compatible, older version).
        @available(macOS, deprecated: 10.8, message: "Use `basic` instead.")
        case basic64 = 5

        /// Counts of specific events on the task.
        case events = 2

        /// Total thread run times for the task.
        case threadTimes = 3

        /// Absolute times for the task.
        case absoluteTimes = 1

        /// Kernel memory information for the task.
        case kernelMemory = 7

        /// The task's security token.
        case securityToken = 13

        /// The task's audit token.
        case auditToken = 15

        /// The task's affinity tag information.
        case affinityTag = 16

        /// Information about dyld images in the task.
        case dyld = 17

        /// Basic information about the task (64-bit compatible, "newer" version).
        /// - Note: This appears to have been introduced in xnu-4570.1.46, which was released with
        /// OS X 10.13. However, it seems to have only been a compatibility patch and wasn't meant
        /// for general use. It also appears to be related to iOS (but since macOS and iOS use the
        /// same kernel, it's available on macOS as well).
        @available(macOS, introduced: 10.13, deprecated: 10.13, message: "Use `basic` instead.")
        case basic64_2 = 18

        /// Information about external modifications to the task.
        case extmod = 19

        /// Basic information about the task.
        case basic = 20

        /// Information about the task's power usage.
        case power = 21

        /// Information about the task's power usage (newer version).
        case powerV2 = 26

        /// Information about the task's virtual memory usage.
        case vm = 22

        /// Information about the task's virtual memory usage, including purgeable memory.
        case vmPurgeable = 23

        /// Time values for how long threads in the task have been in wait states.
        /// - Note: This was introduced in OS X 10.10, but with a code comment saying it was
        /// deprecated and may not be accurate. However, it's still available to this day.
        @available(macOS, introduced: 10.10, deprecated: 10.10, message: "May not be accurate.")
        case waitTimes = 25

        /// The task's flags.
        case flags = 28
    }

    /// Gets the task's info.
    public func getInfo<DataType: BitwiseCopyable>(
        _ info: Info, as type: DataType.Type = DataType.self
    ) throws -> DataType {
        try Mach.callWithCountInOut(type: type) {
            (array: task_info_t, count) in
            task_info(self.name, info.rawValue, array, &count)
        }
    }

    /// Sets the task's info.
    /// - Warning: Currently no information can be set.
    public func setInfo<DataType: BitwiseCopyable>(
        _ info: Info, to value: DataType
    ) throws {
        try Mach.callWithCountIn(value: value) {
            (array: task_info_t, count) in
            task_set_info(self.name, info.rawValue, array, count)
        }
    }
}
