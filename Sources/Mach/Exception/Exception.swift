import Darwin.Mach
import MachBase
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
            try Mach.callWithCountIn(value: code) {
                rawCode, count in
                exception_raise(self.name, thread.name, task.name, exceptionType, rawCode, count)
            }
        }
    }
}
