import Darwin.POSIX
import Foundation
import KassHelpers

/// The BSD kernel.
/// - Important: In some cases, such as if the `Foundation` module is imported, there will be
/// a constant named `BSD` that conflicts with this struct. In those cases, `BSDCore.BSD` may
/// be used to access this struct. This is not required, but it is recommended.
public struct BSD: KassHelpers.Namespace {
    /// Executes a system call and throw an error if it fails.
    public static func syscall(_ syscall: @autoclosure () -> Int32) throws {
        let ret = syscall()
        let code =
            switch ret {
            // While it's not a standard, a return value of -1 usually indicates an error with `errno` set.
            case -1: errno
            // In all other cases, the return value should be the error code.
            default: ret
            }
        guard code == 0 else {
            guard let posixCode = POSIXError.Code(rawValue: errno) else {
                // Let's try again with an `NSError`. We use `NSPOSIXErrorDomain` because this is still a POSIX error (we hope).
                throw NSError(domain: NSPOSIXErrorDomain, code: Int(errno))
            }
            throw POSIXError(posixCode)
        }
        return  // Explicitly return safely.
    }
}
