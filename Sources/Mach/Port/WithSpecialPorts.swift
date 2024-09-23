extension Mach.Port {
    /// A port with special ports.
    public protocol WithSpecialPorts {
        associatedtype SpecialPort: SpecialPortType
        /// Gets a special port.
        /// - Parameters:
        ///   - specialPort: The special port to get.
        ///   - type: The type to reference the port as.
        /// - Throws: An error if the special port cannot be retrieved.
        /// - Returns: The special port.
        func getSpecialPort<PortType: Mach.Port>(
            _ specialPort: SpecialPort, as type: PortType.Type
        ) throws -> PortType

        /// Sets a special port for the task.
        /// - Parameters:
        ///   - specialPort: The special port to set.
        ///   - port: The port to set as the special port.
        /// - Throws: An error if the special port cannot be set.
        func setSpecialPort(_ specialPort: SpecialPort, to port: Mach.Port) throws
    }
    /// A special port for a port.
    public protocol SpecialPortType: RawRepresentable where RawValue == Int32 {
        /// The parent port type.
        associatedtype ParentPort: Mach.Port.WithSpecialPorts

        /// Gets a special port.
        /// - Parameters:
        ///   - parentPort: The port to get the special port for.
        ///   - type: The type to reference the port as.
        /// - Throws: An error if the special port cannot be retrieved.
        /// - Returns: The special port.
        func get<PortType: Mach.Port>(
            for parentPort: ParentPort, as type: PortType.Type
        ) throws -> PortType

        /// Sets a special port.
        /// - Parameters:
        ///   - parentPort: The port to set the special port for.
        ///   - port: The port to set as the special port.
        /// - Throws: An error if the special port cannot be set.
        func set(for parentPort: ParentPort, to port: Mach.Port) throws
    }
}
