import Foundation
import Linking
import MachO

private let bootstrap_look_up:
    @convention(c) (
        _ bp: mach_port_t, _ service_name: UnsafePointer<CChar>,
        _ sp: UnsafeMutablePointer<mach_port_t>
    )
        -> kern_return_t = libSystem().get(symbol: "bootstrap_look_up")!.cast()

private let bootstrap_strerror: @convention(c) (_ ret: kern_return_t) -> UnsafePointer<CChar>? =
    libSystem().get(symbol: "bootstrap_strerror")!.cast()

/// A port for communicating with the bootstrap server.
public class BootstrapPort: MachTaskSpecialPort {
    /// Look up a service by name in the bootstrap server.
    /// - Parameter serviceName: The name of the service to look up.
    /// - Returns: The port for the service.
    public func lookUp(serviceName: String) throws -> MachPortImpl {
        var port = mach_port_t()
        let ret = bootstrap_look_up(self.rawValue, serviceName, &port)
        guard ret == KERN_SUCCESS else {
            guard let errorString = bootstrap_strerror(ret) else {
                // If we can't get the error string, just throw the return code
                throw NSError(domain: NSMachErrorDomain, code: Int(ret))
            }
            throw NSError(
                domain: NSMachErrorDomain, code: Int(ret),
                userInfo: [
                    NSLocalizedDescriptionKey: String(cString: errorString)
                ]
            )
        }
        return MachPortImpl(rawValue: port)
    }
}
