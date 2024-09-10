import Foundation.NSError
import System

extension BSD {
    /// An error that occurred in the kernel.
    public class KernelError: NSError {
        public var typedErrno: Errno? { Errno(rawValue: Int32(self.code)) }
        /// Initialize a new kernel error from `errno`.
        public convenience init() {
            self.init(domain: NSPOSIXErrorDomain, code: Int(errno))
        }
    }
}
