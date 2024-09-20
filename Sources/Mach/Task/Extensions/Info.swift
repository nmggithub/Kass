import Darwin.Mach

extension Mach.Task {
    /// The task's info.
    public var info: Info { Info(about: self) }
    /// A task's info.

    public class Info: Mach.FlavoredDataManagerNoAdditionalArgs<Info.Flavor, task_info_t.Pointee> {
        /// A flavor of task info.
        public enum Flavor: task_flavor_t {
            case absoluteTime = 1
            case events = 2
            case threadTimes = 3
            case basic32 = 4
            case basic64 = 5
            case basic2_32 = 6
            case kernelMemory = 7
            @available(
                *, deprecated,
                message: "This task info flavor is listed as \"obsolete\" in the kernel."
            ) case schedTimeshare = 10
            @available(
                *, deprecated,
                message: "This task info flavor is listed as \"obsolete\" in the kernel."
            ) case rr = 11
            case securityToken = 13
            @available(
                *, deprecated,
                message: "This task info flavor is listed as \"obsolete\" in the kernel."
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

        /// Creates a task info manager.
        /// - Parameter task: The task to manage info about.
        public convenience init(about task: Mach.Task) {
            self.init(
                getter: { flavor, array, count, _ in
                    task_info(task.name, flavor.rawValue, array, &count)
                },
                setter: { flavor, array, count, _ in
                    task_set_info(task.name, flavor.rawValue, array, count)
                }
            )
        }

        /// Gets a task's info.
        /// - Parameters:
        ///   - flavor: The flavor of the info.
        ///   - type: The type to load the info as.
        /// - Throws: An error if the info cannot be retrieved.
        /// - Returns: The task's info.
        public func get<InfoType>(_ flavor: Flavor, as type: InfoType.Type) throws
            -> InfoType
        {
            try super.get(flavor, as: type)
        }

        /// Sets a task's info.
        /// - Parameters:
        ///  - flavor: The flavor of the info.
        ///  - value: The value to set the info to.
        ///  - Throws: An error if the info cannot be set.
        public func set<InfoType>(_ flavor: Flavor, to value: consuming InfoType) throws {
            try super.set(flavor, to: value)
        }
    }
}
