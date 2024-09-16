import Foundation.NSError
import System

extension BSD {
    /// An error that occurred in the BSD kernel.
    public class Error: NSError {
        public var typedErrno: Errno? { Errno(rawValue: Int32(self.code)) }
        /// Initialize a new kernel error, defaulting to `errno`.
        public convenience init(_ code: Int32 = errno) {
            self.init(domain: NSPOSIXErrorDomain, code: Int(code))
        }
    }
}
