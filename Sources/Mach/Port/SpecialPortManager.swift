import Darwin.Mach

extension Mach.Port {
    public struct SpecialPortManager<ParentPortType: Mach.Port, SpecialPort: RawRepresentable> {
        public init(
            parentPort: ParentPortType,
            getter: @escaping Getter,
            setter: @escaping Setter
        ) {
            self.getter = getter
            self.setter = setter
            self.parentPort = parentPort
        }

        /// A block that calls a syscall to get a special port.
        public typealias Getter = (
            ParentPortType, SpecialPort, inout mach_port_name_t
        ) -> kern_return_t
        /// The block that calls a syscall to get a special port.
        let getter: Getter

        /// A block that calls a syscall to set a special port.
        public typealias Setter = (ParentPortType, SpecialPort, mach_port_name_t) ->
            kern_return_t
        /// The block that calls a syscall to set a special port.
        let setter: Setter

        /// The "parent" port.
        let parentPort: ParentPortType

        /// Get a special port.
        /// - Parameters:
        ///   - specialPort: The special port type.
        ///   - portType: The type to reference the port as.
        /// - Throws: An error if the port cannot be retrieved.
        /// - Returns: The special port.
        public func get<PortType: Mach.Port>(_ specialPort: SpecialPort, as portType: PortType.Type)
            throws
            -> PortType
        {
            var portName = mach_port_name_t()
            try Mach.Call(self.getter(self.parentPort, specialPort, &portName))
            return PortType(named: portName)
        }
        /// Set a special port.
        /// - Parameters:
        ///   - specialPort: The type of special port to set.
        ///   - port: The port to set as the special port.
        /// - Throws: An error if the port cannot be set.
        public func set(_ specialPort: SpecialPort, to port: Mach.Port) throws {
            try Mach.Call(self.setter(self.parentPort, specialPort, port.name))
        }
    }
}
