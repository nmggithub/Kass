extension Mach.PortDisposition: Hashable {}

extension Mach.Message {
    /// A port right contained in a message.
    public struct PortRight: Equatable, Hashable {
        /// The port the right is for.
        public let port: Mach.Port
        /// The disposition to apply to the port to get the right.
        public let disposition: Mach.PortDisposition
    }
    /// The port rights in a message.
    public struct PortRights {
        /// The message.
        let message: Mach.Message
        /// Gets the port rights from the message.
        /// - Parameter message: The message.
        public init(message: Mach.Message) {
            self.message = message
        }
        /// The local port right in the message.
        /// - Note: This is, conventionally, a send right for the remote task to use as a reply port.
        public var local: PortRight {
            get {
                PortRight(
                    port: self.message.header.localPort,
                    disposition: self.message.header.bits.localPortDisposition
                )
            }
            set {
                self.message.header.localPort = newValue.port
                self.message.header.bits.localPortDisposition = newValue.disposition
            }
        }
        /// The remote port right in the message.
        /// - Note: This is the port the message is sent to. Use the ``Mach/Port/Disposition/copySend`` disposition to keep the send right.
        public var remote: PortRight {
            get {
                PortRight(
                    port: self.message.header.remotePort,
                    disposition: self.message.header.bits.remotePortDisposition
                )
            }
            set {
                self.message.header.remotePort = newValue.port
                self.message.header.bits.remotePortDisposition = newValue.disposition
            }
        }
        /// The additional port rights in the message.
        /// - Important: This is a read-only set of port rights contained in the message body. Use the body directly to modify the rights.
        var additional: Set<PortRight> {
            var portRights: Set<PortRight> = []
            self.message.body?.descriptors.forEach { descriptor in
                if descriptor is Mach.Message.Body.PortDescriptor {
                    let portDescriptor = descriptor as! Mach.Message.Body.PortDescriptor
                    portRights.insert(
                        PortRight(
                            port: portDescriptor.port,
                            disposition: portDescriptor.disposition
                        ))
                }
                if descriptor is Mach.Message.Body.GuardedPortDescriptor {
                    let portDescriptor = descriptor as! Mach.Message.Body.GuardedPortDescriptor
                    portRights.insert(
                        PortRight(
                            port: portDescriptor.port,
                            disposition: portDescriptor.disposition
                        ))
                }
                if descriptor is Mach.Message.Body.OOLPortsDescriptor {
                    let portDescriptor = descriptor as! Mach.Message.Body.OOLPortsDescriptor
                    portRights.formUnion(
                        portDescriptor.ports.map {
                            PortRight(
                                port: $0,
                                disposition: portDescriptor.disposition
                            )
                        }
                    )

                }
            }
            return portRights
        }
    }
}
