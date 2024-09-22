import Darwin.Mach

extension Mach.Thread {
    /// A special port for a thread.
    public enum SpecialPort: task_special_port_t {
        case kernel = 1
        case inspect = 2
        case read = 3
    }

    /// Gets a special port for the thread.
    /// - Parameters:
    ///   - specialPort: The special port to get.
    ///   - as: The type to reference the port as.
    /// - Throws: An error if the port cannot be retrieved.
    /// - Returns: The special port.
    public func getSpecialPort<PortType: Mach.Port>(
        _ specialPort: SpecialPort, as: PortType.Type = Mach.Port.self
    ) throws -> PortType {
        var portName = mach_port_name_t()
        try Mach.call(
            thread_get_special_port(self.name, specialPort.rawValue, &portName)
        )
        return PortType(named: portName)
    }

    /// Sets a special port for the thread.
    /// - Parameters:
    ///   - specialPort: The special port to set.
    ///   - port: The port to set as the special port.
    /// - Throws: An error if the port cannot be set.
    public func setSpecialPort(_ specialPort: SpecialPort, to port: Mach.Port) throws {
        try Mach.call(
            thread_set_special_port(self.name, specialPort.rawValue, port.name)
        )
    }
}
