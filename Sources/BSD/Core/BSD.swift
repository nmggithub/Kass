import Darwin.POSIX
import Foundation
import KassHelpers

/// The BSD kernel.
public struct BSD: KassHelpers.Namespace {
    /// Executes a system call and throw an error if it fails.
    @discardableResult  // Most of the time, users won't care about the return value, but we still want it to be available.
    public static func syscall<ReturnType: BinaryInteger>(_ syscall: @autoclosure () -> ReturnType)
        throws -> ReturnType
    {
        let ret = syscall()
        guard ret != -1 else {
            let currentErrno = copy errno  // Make a copy to avoid potential race conditions.
            guard let posixCode = POSIXError.Code(rawValue: currentErrno) else {
                // Let's try again with an `NSError`. We use `NSPOSIXErrorDomain` because this is still a POSIX error (we hope).
                throw NSError(domain: NSPOSIXErrorDomain, code: Int(currentErrno))
            }
            throw POSIXError(posixCode)
        }
        return ret
    }
}
