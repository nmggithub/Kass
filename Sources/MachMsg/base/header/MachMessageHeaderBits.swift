import Darwin.Mach
import MachPort

private let MACH_MSGH_BITS_PORTS_MASK = UInt32(
    MACH_MSGH_BITS_REMOTE_MASK | MACH_MSGH_BITS_LOCAL_MASK | MACH_MSGH_BITS_VOUCHER_MASK
)

/// The configuration bits of a Mach message header.
public struct MachMessageHeaderBits: RawRepresentable {
    /// The raw configuration bits.
    public var rawValue: mach_msg_bits_t {
        (self.otherBits & ~MACH_MSGH_BITS_PORTS_MASK)
            | self.remoteBits
            | self.localBits << 8
            | self.voucherBits << 16
    }
    /// Represent existing raw configuration bits.
    /// - Parameter rawValue: The raw configuration bits.
    public init(rawValue: mach_msg_bits_t) {
        self.remoteBits = rawValue & mach_msg_type_name_t(MACH_MSGH_BITS_REMOTE_MASK)
        self.localBits = (rawValue & mach_msg_type_name_t(MACH_MSGH_BITS_LOCAL_MASK)) >> 8
        self.voucherBits = (rawValue & mach_msg_type_name_t(MACH_MSGH_BITS_VOUCHER_MASK)) >> 16
        self.otherBits = rawValue & ~MACH_MSGH_BITS_PORTS_MASK
    }

    /// The raw remote port disposition.
    var remoteBits: mach_msg_type_name_t
    /// The raw local port disposition.
    var localBits: mach_msg_type_name_t
    /// The raw voucher port disposition.
    var voucherBits: mach_msg_type_name_t
    /// The other configuration bits.
    var otherBits: UInt32
}

extension MachMessageHeaderBits {
    /// The remote port disposition.
    var remotePortDisposition: MachPortDisposition {
        get { MachPortDisposition(rawValue: self.remoteBits) ?? .unknown }
        set { self.remoteBits = newValue.rawValue }
    }
    /// The local port disposition.
    var localPortDisposition: MachPortDisposition {
        get { MachPortDisposition(rawValue: self.localBits) ?? .unknown }
        set { self.localBits = newValue.rawValue }
    }
    /// The voucher port disposition.
    var voucherPortDisposition: MachPortDisposition {
        get { MachPortDisposition(rawValue: self.voucherBits) ?? .unknown }
        set { self.voucherBits = newValue.rawValue }
    }
    var isMessageComplex: Bool {
        get { self.otherBits & MACH_MSGH_BITS_COMPLEX != 0 }
        set { self.otherBits |= MACH_MSGH_BITS_COMPLEX }
    }
}
