import Darwin.Mach
import Foundation.NSError

extension Mach.Task {
    /// Get the task's stashed ports.
    /// - Throws: An error if the ports cannot be retrieved.
    /// - Returns: The stashed ports.
    public func getStashedPorts() throws -> [Mach.Port] {
        var portsCount = mach_msg_type_number_t.max
        var ports: mach_port_array_t? = mach_port_array_t.allocate(
            capacity: Int(portsCount)
        )
        let ret = mach_ports_lookup(self.name, &ports, &portsCount)
        guard ret == KERN_SUCCESS else {
            throw NSError(domain: NSMachErrorDomain, code: Int(ret))
        }
        return (0..<Int(portsCount)).map {
            let port = Mach.Port(named: ports![$0])
            port.owningTask = self
            return port
        }
    }

    /// Set the task's stashed ports.
    /// - Parameter ports: The ports to stash.
    /// - Throws: An error if the ports cannot be set.
    public func setStashedPorts(_ ports: [Mach.Port]) throws {
        let portsCount = mach_msg_type_number_t(ports.count)
        var portNames = ports.map(\.name)
        let ret = mach_ports_register(self.name, &portNames, portsCount)
        guard ret == KERN_SUCCESS else {
            throw NSError(domain: NSMachErrorDomain, code: Int(ret))
        }
    }
}
