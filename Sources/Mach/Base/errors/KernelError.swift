import Foundation.NSError

extension Mach {
    /// An error that occurred in the kernel.
    public class KernelError: NSError {
        /// The kernel return code.
        public var kernelReturn: KernReturn { KernReturn(rawValue: Int32(self.code)) ?? .unknown }
        /// Initializes a new kernel error from a kernel return code.
        /// - Parameter kr: The kernel return code.
        public convenience init(_ kr: kern_return_t) {
            // Using the `NSMachErrorDomain` domain seems to cause NSError to automatically generate a proper error description.
            self.init(domain: NSMachErrorDomain, code: Int(kr))
        }
    }
}