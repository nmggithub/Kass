extension Mach {
    /// A port with special ports.
    internal protocol PortWithSpecialPorts {
        associatedtype SpecialPort: SpecialPortType
        /// Gets a special port.
        func getSpecialPort<PortType: Mach.Port>(
            _ specialPort: SpecialPort, as type: PortType.Type
        ) throws -> PortType

        /// Sets a special port.
        func setSpecialPort(_ specialPort: SpecialPort, to port: Mach.Port) throws
    }
    /// A special port for a port.
    internal protocol SpecialPortType: Mach.OptionEnum
    where RawValue == Int32, ParentPort.SpecialPort == Self {
        /// The parent port type.
        associatedtype ParentPort: Mach.PortWithSpecialPorts

        /// Gets a special port.
        func get<PortType: Mach.Port>(
            for parentPort: ParentPort, as type: PortType.Type
        ) throws -> PortType

        /// Sets a special port.
        func set(for parentPort: ParentPort, to port: Mach.Port) throws
    }
}

extension Mach.SpecialPortType {
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
