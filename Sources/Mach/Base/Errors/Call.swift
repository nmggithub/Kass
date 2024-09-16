import Darwin.Mach

extension Mach {
    /// Execute a call and throw an error if it fails.
    /// - Parameter call: A statement that executes a call and returns a kernel return code.
    /// - Throws: An error if the call fails.
    public static func Call(_ call: @autoclosure () -> kern_return_t) throws {
        let kr = call()
        guard kr == KERN_SUCCESS else { throw Mach.Error(kr) }
    }
}
