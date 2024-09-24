import Darwin.Mach
import Foundation.NSError
import Linking

private let bootstrap_look_up:
    @convention(c) (
        _ bp: mach_port_t, _ service_name: UnsafePointer<CChar>,
        _ sp: UnsafeMutablePointer<mach_port_t>
    )
        -> kern_return_t = libSystem().get(symbol: "bootstrap_look_up")!.cast()

private let bootstrap_strerror: @convention(c) (_ ret: kern_return_t) -> UnsafePointer<CChar>? =
    libSystem().get(symbol: "bootstrap_strerror")!.cast()

extension Mach {
    /// A port for communicating with the bootstrap server.
    public class BootstrapPort: Mach.Port {
        /// Looks up a service by name.
        public func lookUp(serviceName: String) throws -> Mach.Port {
            var portName = mach_port_name_t()
            do {
                try Mach.call(bootstrap_look_up(self.name, serviceName, &portName))
            } catch {
                switch error {
                case is MachError: throw error
                default:
                    let kr = kern_return_t((error as NSError).code)
                    guard let errorString = bootstrap_strerror(kr) else {
                        throw error  // Re-throw the original error if we can't get an error string.
                    }
                    throw NSError(
                        domain: NSMachErrorDomain, code: Int(kr),
                        userInfo: [
                            NSLocalizedDescriptionKey: String(cString: errorString)
                        ]
                    )
                }
            }
            return Mach.Port(named: portName)
        }
    }
}

extension Mach.Task {
    /// The task's bootstrap port.
    public var bootstrapPort: Mach.BootstrapPort {
        get throws {
            try self.getSpecialPort(.bootstrap, as: Mach.BootstrapPort.self)
        }
    }
}
