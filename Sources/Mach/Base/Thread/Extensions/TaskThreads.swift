import Darwin.Mach

extension Mach.Task {
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
}
