extension Mach.Port {
    /// A port with special ports.
    public protocol WithSpecialPorts {
        associatedtype SpecialPort: SpecialPortType
        /// Gets a special port.
        func getSpecialPort<PortType: Mach.Port>(
            _ specialPort: SpecialPort, as type: PortType.Type
        ) throws -> PortType

        /// Sets a special port.
        func setSpecialPort(_ specialPort: SpecialPort, to port: Mach.Port) throws
    }
    /// A special port for a port.
    public protocol SpecialPortType: RawRepresentable where RawValue == Int32 {
        /// The parent port type.
        associatedtype ParentPort: Mach.Port.WithSpecialPorts

        /// Gets a special port.
        func get<PortType: Mach.Port>(
            for parentPort: ParentPort, as type: PortType.Type
        ) throws -> PortType

        /// Sets a special port.
        func set(for parentPort: ParentPort, to port: Mach.Port) throws
    }
}
