import Darwin.Mach
import MachBase
import MachPort
import MachTask
import MachThread

extension Mach {
    /// An exception port.
    class Exception: Mach.Port {
        public func raise(
            in thread: Mach.Thread,
            in task: Mach.Task,
            ofType exceptionType: exception_type_t,
            code: Int
        ) throws {
            try Mach.SyscallWithCountIn(arrayType: exception_data_t.self, data: Int.self) {
                code, count in
                exception_raise(self.name, thread.name, task.name, exceptionType, code, count)
            }
        }
    }
}
