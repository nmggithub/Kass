import Darwin.Mach
import Foundation.NSError
import Linking
import MachBase
import MachPort

private let bootstrap_look_up:
    @convention(c) (
        _ bp: mach_port_t, _ service_name: UnsafePointer<CChar>,
        _ sp: UnsafeMutablePointer<mach_port_t>
    )
        -> kern_return_t = libSystem().get(symbol: "bootstrap_look_up")!.cast()

private let bootstrap_strerror: @convention(c) (_ ret: kern_return_t) -> UnsafePointer<CChar>? =
    libSystem().get(symbol: "bootstrap_strerror")!.cast()

extension Mach.Task {
    public var bootstrapPort: BootstrapPort {
        get throws {
            try self.specialPorts.get(.bootstrap, as: BootstrapPort.self)
        }
    }
    /// A port for communicating with the bootstrap server.
    public class BootstrapPort: Mach.Port {
        /// Look up a service by name.
        /// - Parameter serviceName: The name of the service to look up.
        /// - Throws: An error if the service lookup failed.
        /// - Returns: The port for the service.
        public func lookUp(serviceName: String) throws -> Mach.Port {
            var portName = mach_port_name_t()
            let ret = bootstrap_look_up(self.name, serviceName, &portName)
            guard ret == KERN_SUCCESS else {
                guard let errorString = bootstrap_strerror(ret) else {
                    // If we can't get the error string, throw the return code only
                    throw NSError(domain: NSMachErrorDomain, code: Int(ret))
                }
                throw NSError(
                    domain: NSMachErrorDomain, code: Int(ret),
                    userInfo: [
                        NSLocalizedDescriptionKey: String(cString: errorString)
                    ]
                )
            }
            return Mach.Port(named: portName)
        }
    }
}