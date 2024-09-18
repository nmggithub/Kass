import Darwin.POSIX

extension BSD {
    /// Execute a system call and throw an error if it fails.
    /// - Parameter syscall: A statement that executes a syscall and returns the result.
    /// - Throws: An error if the syscall fails.
    public static func Syscall(_ syscall: @autoclosure () -> Int32) throws {
        let ret = syscall()
        switch ret {
        case -1:
            // While it's not a standard, a return value of -1 usually indicates an error with `errno` set.
            throw BSD.Error(errno)
        case 0:
            return  // success
        default:
            throw BSD.Error(ret)
        }
    }
}
