import Darwin.Mach

extension Mach.Task {
    /// The task's info.
    public var info: Info { Info(about: self) }
    /// A task's info.
    public struct Info {
        public typealias ArrayPointee = task_info_t.Pointee
        public let task: Mach.Task
        /// Get a task's info.
        /// - Parameter task: The task get the info of.
        public init(about task: Mach.Task) {
            self.task = task
        }
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
        /// Get a task's info.
        /// - Parameters:
        ///   - flavor: The flavor of the info.
        ///   - type: The type to load the info as.
        /// - Throws: An error if the info cannot be retrieved.
        public func get<InfoType>(_ flavor: Flavor, as type: InfoType.Type) throws -> InfoType {
            var count = mach_msg_type_number_t(
                MemoryLayout<InfoType>.size / MemoryLayout<task_info_t.Pointee>.size
            )
            let arrayPointer = task_info_t.allocate(capacity: Int(copy count))
            defer { arrayPointer.deallocate() }
            try Mach.Syscall(task_info(self.task.name, flavor.rawValue, arrayPointer, &count))
            return UnsafeMutableRawPointer(arrayPointer).load(as: InfoType.self)
        }
        /// Get a task's info.
        /// - Parameters:
        ///   - flavor: The flavor of the info.
        ///   - count: The size of the info, in `integer_t`'s.
        /// - Throws: An error if the info cannot be retrieved.
        /// - Important: This function is for advanced use only. ``get(_:as:)`` is recommended.
        public func get(
            _ flavor: Flavor,
            count: inout mach_msg_type_number_t
        ) throws -> task_info_t {
            let arrayPointer = task_info_t.allocate(capacity: Int(copy count))
            try Mach.Syscall(
                task_info(self.task.name, flavor.rawValue, arrayPointer, &count)
            )
            return arrayPointer
        }

        /// Set a task's info.
        /// - Parameters:
        ///   - flavor: The flavor of the info.
        ///   - value: The value to set the info to.
        /// - Throws: An error if the info cannot be set.
        /// - Warning: The kernel seems to always return an error for this function, but it is still included for completeness.
        public func set<InfoType>(_ flavor: Flavor, to value: consuming InfoType) throws {
            let count = mach_msg_type_number_t(
                MemoryLayout<InfoType>.size / MemoryLayout<integer_t>.size
            )
            let valuePointer = UnsafeMutablePointer<task_info_t.Pointee>.allocate(
                capacity: Int(count)
            )
            defer { valuePointer.deallocate() }
            withUnsafeBytes(of: value) { valueBytes in
                UnsafeMutableRawPointer(valuePointer).copyMemory(
                    from: valueBytes.baseAddress!, byteCount: valueBytes.count
                )
            }
            task_set_info(self.task.name, flavor.rawValue, valuePointer, count)
        }
    }
}
