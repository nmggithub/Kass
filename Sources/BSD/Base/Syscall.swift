import Darwin.POSIX
import Foundation
import System

extension POSIXError {
    /// Initializes a new POSIX error with a given code.
    /// - Parameter code: The error code.
    public init(_ code: Int32) {
        guard let typedCode = POSIXError.Code(rawValue: code) else {
            fatalError("Invalid POSIX error code: \(code)")
        }
        self.init(typedCode)
    }
    /// The error code as an `Errno`.
    @available(macOS 11.0, *)
    public var typedErrno: Errno? { Errno(rawValue: Int32(self.code.rawValue)) }
}

extension BSD {
    typealias Error = POSIXError
    /// Executes a system call and throw an error if it fails.
    /// - Parameter syscall: A statement that executes a syscall and returns the result.
    /// - Throws: An error if the syscall fails.
    public static func syscall(_ syscall: @autoclosure () -> Int32) throws {
        let ret = syscall()
        switch ret {
        case -1:
            // While it's not a standard, a return value of -1 usually indicates an error with `errno` set.
            throw POSIXError(errno)
        case 0:
            return  // success
        default:
            throw POSIXError(ret)
        }
    }
}
