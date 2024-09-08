import Darwin.Mach
import MachBase
import MachPort
import MachThread

extension Mach.Task {
    /// The threads in the task.
    public var threads: [Mach.Thread] {
        get throws {
            var threadList: thread_act_array_t?
            var threadCount = mach_msg_type_number_t.max
            try Mach.Syscall(task_threads(self.name, &threadList, &threadCount))
            return (0..<Int(threadCount)).map {
                Mach.Thread(named: threadList![$0])
            }
        }
    }
}
