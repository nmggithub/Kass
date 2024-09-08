import Darwin.Mach

extension Mach {
    /// Execute a system call and throw an error if it fails.
    /// - Parameter syscall: A statement that executes a syscall and returns the result.
    /// - Throws: An error if the syscall fails.
    public static func Syscall(_ syscall: @autoclosure () -> kern_return_t) throws {
        let kr = syscall()
        guard kr != KERN_SUCCESS else { throw Mach.KernelError(kr) }
    }
}
