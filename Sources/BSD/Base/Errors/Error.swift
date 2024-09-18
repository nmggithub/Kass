import Foundation.NSError
import System

extension BSD {
    /// An error that occurred in the BSD kernel.
    public class Error: NSError, @unchecked Sendable {
        /// The error code as an `Errno`.
        public var typedErrno: Errno? { Errno(rawValue: Int32(self.code)) }
        /// Initialize a new kernel error with a given code.
        public convenience init(_ code: Int32) {
            self.init(domain: NSPOSIXErrorDomain, code: Int(code))
        }
    }
}
