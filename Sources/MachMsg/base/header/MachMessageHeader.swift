import CCompat
import MachO
import MachPort

/// A Mach message header.
public struct MachMessageHeader: RawRepresentable {
    /// The raw message header.
    public var rawValue: mach_msg_header_t {
        mach_msg_header_t(
            msgh_bits: self.bits.rawValue,
            msgh_size: self.messageSize,
            msgh_remote_port: self.remotePort.rawValue,
            msgh_local_port: self.localPort.rawValue,
            msgh_voucher_port: self.voucherPort.rawValue,
            msgh_id: self.messageID
        )
    }
    /// Represent an existing raw message header.
    /// - Parameter rawValue: The raw message header.
    public init(rawValue: mach_msg_header_t) {
        self.bits = MachMessageHeaderBits(rawValue: rawValue.msgh_bits)
        self.messageSize = rawValue.msgh_size
        self.remotePort = MachPort(rawValue: rawValue.msgh_remote_port)
        self.localPort = MachPort(rawValue: rawValue.msgh_local_port)
        self.voucherPort = MachPort(rawValue: rawValue.msgh_voucher_port)
        self.messageID = rawValue.msgh_id
    }
    /// The configuration bits.
    var bits: MachMessageHeaderBits
    /// The advertised message size.
    var messageSize: mach_msg_size_t
    /// The remote port.
    var remotePort: MachPort
    /// The local port.
    var localPort: MachPort
    /// The voucher port.
    var voucherPort: MachPort
    /// The message ID.
    var messageID: mach_msg_id_t
    /// Create a new message header.
    public init() { self.init(rawValue: mach_msg_header_t()) }
}

extension MachMessageHeader {
    /// The local port with an associated right type.
    var localMessagePort: MachMessagePort {
        get {
            MachMessagePort(
                rawPort: self.localPort.rawValue, disposition: self.bits.localPortDisposition
            )
        }
        set {
            self.localPort.rawValue = newValue.rawValue
            self.bits.localPortDisposition = newValue.disposition
        }
    }
    /// The remote port with an associated right type.
    var remoteMessagePort: MachMessagePort {
        get {
            MachMessagePort(
                rawPort: self.remotePort.rawValue, disposition: self.bits.remotePortDisposition
            )
        }
        set {
            self.remotePort.rawValue = newValue.rawValue
            self.bits.remotePortDisposition = newValue.disposition
        }
    }
    /// The voucher port with an associated right type.
    var voucherMessagePort: MachMessagePort {
        get {
            MachMessagePort(
                rawPort: self.voucherPort.rawValue, disposition: self.bits.voucherPortDisposition
            )
        }
        set {
            self.voucherPort.rawValue = newValue.rawValue
            self.bits.voucherPortDisposition = newValue.disposition
        }
    }
}
