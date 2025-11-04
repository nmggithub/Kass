import Darwin.Mach
import Foundation.NSError
import Linking

#if canImport(Bootstrap)
    import Bootstrap
#else
    private let bootstrap_strerror: @convention(c) (kern_return_t) -> UnsafeMutablePointer<CChar>? =
        libSystem.get(symbol: "bootstrap_strerror")!.cast()
    private let bootstrap_parent:
        @convention(c) (mach_port_t, UnsafeMutablePointer<mach_port_name_t>) -> kern_return_t =
            libSystem.get(symbol: "bootstrap_parent")!.cast()
    private let bootstrap_look_up:
        @convention(c) (mach_port_t, UnsafePointer<CChar>, UnsafeMutablePointer<mach_port_name_t>)
            -> kern_return_t =
            libSystem.get(symbol: "bootstrap_look_up")!.cast()
    private let bootstrap_check_in:
        @convention(c) (mach_port_t, UnsafePointer<CChar>, UnsafeMutablePointer<mach_port_name_t>)
            -> kern_return_t =
            libSystem.get(symbol: "bootstrap_check_in")!.cast()
    private let bootstrap_register:
        @convention(c) (mach_port_t, UnsafePointer<CChar>, mach_port_t) -> kern_return_t =
            libSystem.get(symbol: "bootstrap_register")!.cast()
    private let BOOTSTRAP_MAX_NAME_LEN: Int32 = 128
#endif  // canImport(Bootstrap)

private let bootstrap_get_root_:
    @convention(c) (mach_port_t, UnsafeMutablePointer<mach_port_name_t>) -> kern_return_t =
        libSystem.get(symbol: "bootstrap_get_root")!.cast()

private let bootstrap_register_:
    @convention(c) (mach_port_t, UnsafeMutablePointer<CChar>, mach_port_t) -> kern_return_t =
        libSystem.get(symbol: "bootstrap_register")!.cast()

private let bootstrap_unprivileged_:
    @convention(c) (mach_port_t, UnsafeMutablePointer<mach_port_name_t>) -> kern_return_t =
        libSystem.get(symbol: "bootstrap_unprivileged")!.cast()

extension Mach {
    /// A port for communicating with the bootstrap server.
    public class BootstrapPort: Mach.Port {
        /// Calls a bootstrap function and handles errors.
        private static func call(_ call: @autoclosure () -> kern_return_t) throws {
            do {
                try Mach.call(call())
            } catch {
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

        /// The parent bootstrap port.
        public var parentPort: BootstrapPort? {
            get throws {
                var parentPortName = mach_port_name_t()
                try Self.call(bootstrap_parent(self.name, &parentPortName))
                return BootstrapPort(named: parentPortName)
            }
        }

        /// The unprivileged bootstrap port.
        public var unprivilegedPort: Mach.Port {
            get throws {
                var unprivilegedPortName = mach_port_name_t()
                try Self.call(bootstrap_unprivileged_(self.name, &unprivilegedPortName))
                return Mach.Port(named: unprivilegedPortName)
            }
        }

        /// The root bootstrap port.
        public var rootPort: Mach.Port {
            get throws {
                var rootPortName = mach_port_name_t()
                try Self.call(bootstrap_get_root_(self.name, &rootPortName))
                return Mach.Port(named: rootPortName)
            }
        }

        /// Looks up a service by name.
        public func lookUp<PortType: Mach.Port>(serviceName: String) throws -> PortType {
            var portName = mach_port_name_t()
            try Self.call(bootstrap_look_up(self.name, serviceName, &portName))
            return PortType(named: portName)
        }

        /// Registers a service with the bootstrap server.
        // - Warning: This function will truncate the service name if it is longer than `BOOTSTRAP_MAX_NAME_LEN`.
        public func register(serviceName: String, port: Mach.Port) throws {
            var serviceNameChars = [CChar](repeating: 0, count: Int(BOOTSTRAP_MAX_NAME_LEN))
            for i in 0..<min(serviceName.count, Int(BOOTSTRAP_MAX_NAME_LEN)) {
                serviceNameChars[i] = serviceName.utf8CString[i]
            }
            try Self.call(bootstrap_register_(self.name, &serviceNameChars, port.name))
        }

        /// Checks in for a service with the bootstrap server.
        // - Warning: This function will truncate the service name if it is longer than `BOOTSTRAP_MAX_NAME_LEN`.
        public func checkIn(serviceName: String) throws -> Mach.Port {
            var serviceNameChars = [CChar](repeating: 0, count: Int(BOOTSTRAP_MAX_NAME_LEN))
            for i in 0..<min(serviceName.count, Int(BOOTSTRAP_MAX_NAME_LEN)) {
                serviceNameChars[i] = serviceName.utf8CString[i]
            }
            var receiveRight = mach_port_t(MACH_PORT_NULL)
            try Self.call(bootstrap_check_in(self.name, &serviceNameChars, &receiveRight))
            return Mach.Port(named: receiveRight)
        }
    }
}

extension Mach.Task {
    /// The task's bootstrap port.
    public var bootstrapPort: Mach.BootstrapPort {
        get throws { try self.getSpecialPort(.bootstrap) }
    }
}
