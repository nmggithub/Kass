import Darwin.Mach
import Foundation

extension Mach.Port {
    /// A port that can be allocated.
    public protocol Deallocatable: Mach.Port {
        /// Deallocate the port.
        func deallocate() throws
    }
}

extension Mach.Port.Deallocatable {
    public func deallocate() throws {
        let ret = mach_port_deallocate(self.owningTask.name, self.name)
        guard ret == KERN_SUCCESS else {
            throw NSError(domain: NSMachErrorDomain, code: Int(ret))
        }
    }
}
