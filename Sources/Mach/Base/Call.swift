import Darwin.Mach
import Foundation

extension Mach {
    /// Calls the kernel and throws an error if the call fails.
    /// - Parameter call: A statement that executes a kernel call and returns the kernel return code.
    /// - Throws: A `MachError` for basic Mach errors, or an `NSError` for other Mach errors (such as a `mach_msg_return_t`).
    public static func call(_ call: @autoclosure () -> kern_return_t) throws {
        let kr = call()
        // We also throw the NSError if the code is not recognized by MachError (see above).
        guard kr == KERN_SUCCESS else {
            guard let typedCode = MachError.Code(rawValue: kr) else {
                // Let's try again with an `NSError`. We use `NSMachErrorDomain` because this is still a Mach error (we hope).
                throw NSError(domain: NSMachErrorDomain, code: Int(kr))
            }
            throw MachError(typedCode)
        }
    }
}
