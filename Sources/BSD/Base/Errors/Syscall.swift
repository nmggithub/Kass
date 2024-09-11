extension BSD {
    /// Execute a system call and throw an error if it fails.
    /// - Parameter syscall: A statement that executes a syscall and returns the result.
    /// - Throws: An error if the syscall fails.
    public static func Syscall(_ syscall: @autoclosure () -> Int32) throws {
        let ret = syscall()
        guard ret == 0 else { throw BSD.KernelError() }  // ignore the return value (BSD.KernelError will, instead, check the errno)
    }
}
