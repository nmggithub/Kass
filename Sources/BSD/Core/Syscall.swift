import Darwin.POSIX
import Foundation
import System

extension BSD {
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
                throw NSError(domain: NSPOSIXErrorDomain, code: Int(errno))
            }
            throw POSIXError(posixCode)
        }
        return  // Explicitly return safely.
    }
}
