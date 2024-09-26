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
    public protocol SpecialPortType: RawRepresentable
    where RawValue == Int32, ParentPort.SpecialPort == Self {
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

extension Mach.Port.SpecialPortType {
    /// Gets a special port.
    public func get<PortType: Mach.Port>(
        for parentPort: ParentPort, as type: PortType.Type = PortType.self
    ) throws -> PortType {
        try parentPort.getSpecialPort(self, as: type)
    }

    /// Sets a special port.
    public func set(for parentPort: ParentPort, to port: Mach.Port) throws {
        try parentPort.setSpecialPort(self, to: port)
    }
}
