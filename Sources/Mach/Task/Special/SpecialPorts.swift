import Darwin.Mach

extension Mach.Task {
    /// A special port for a task.
    public enum SpecialPort: task_special_port_t {
        case kernel = 1
        case host = 2
        case name = 3
        case bootstrap = 4
        case inspection = 5
        case read = 6
        // @available(
        //     *, deprecated, message: "This task special port type is commented out in the kernel."
        // )
        case seatbelt = 7
        // @available(
        //     *, deprecated, message: "This task special port type is commented out in the kernel."
        // )
        case gssd = 8
        case access = 9
        case debugControl = 10
        case resourceNotify = 11
    }

    /// Gets a special port for the task.
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
            task_get_special_port(self.name, specialPort.rawValue, &portName)
        )
        return PortType(named: portName)
    }

    /// Sets a special port for the task.
    /// - Parameters:
    ///   - specialPort: The special port to set.
    ///   - port: The port to set as the special port.
    /// - Throws: An error if the port cannot be set.
    public func setSpecialPort(_ specialPort: SpecialPort, to port: Mach.Port) throws {
        try Mach.call(
            task_set_special_port(self.name, specialPort.rawValue, port.name)
        )
    }
}
