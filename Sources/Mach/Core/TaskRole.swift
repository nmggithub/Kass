import Darwin.Mach

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
    public var role: Mach.TaskRole? {
        get throws { try Mach.TaskRole(rawValue: self.categoryPolicy.role.rawValue) }
    }

    /// Sets the task's role.
    public func setRole(_ role: Mach.TaskRole) throws {
        try self.setPolicy(.category, to: task_category_policy(role: task_role(role.rawValue)))
    }
}