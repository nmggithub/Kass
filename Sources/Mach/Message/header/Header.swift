import Darwin.Mach
import MachPort

extension Mach.Message {
    /// A message header.
    public struct Header: RawRepresentable {
        /// The raw message header.
        public var rawValue: mach_msg_header_t {
            mach_msg_header_t(
                msgh_bits: self.bits.rawValue,
                msgh_size: self.messageSize,
                msgh_remote_port: self.remotePort.name,
                msgh_local_port: self.localPort.name,
                msgh_voucher_port: self.voucherPort.name,
                msgh_id: self.messageID
            )
        }
        /// Represent an existing raw message header.
        /// - Parameter rawValue: The raw message header.
        public init(rawValue: mach_msg_header_t) {
            self.bits = Bits(rawValue: rawValue.msgh_bits)
            self.messageSize = rawValue.msgh_size
            self.remotePort = Mach.Port(named: rawValue.msgh_remote_port)
            self.localPort = Mach.Port(named: rawValue.msgh_local_port)
            self.voucherPort = Mach.Port(named: rawValue.msgh_voucher_port)
            self.messageID = rawValue.msgh_id
        }
        /// The configuration bits.
        public var bits: Bits
        /// The advertised message size.
        public var messageSize: mach_msg_size_t
        /// The remote port.
        public var remotePort: Mach.Port
        /// The local port.
        public var localPort: Mach.Port
        /// The voucher port.
        public var voucherPort: Mach.Port
        /// The message ID.
        public var messageID: mach_msg_id_t
        /// Create a new message header.
        public init() { self.init(rawValue: mach_msg_header_t()) }
    }
}
