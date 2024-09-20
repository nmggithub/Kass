import Darwin.Mach

private let MACH_MSGH_BITS_PORTS_MASK = UInt32(
    MACH_MSGH_BITS_REMOTE_MASK | MACH_MSGH_BITS_LOCAL_MASK | MACH_MSGH_BITS_VOUCHER_MASK
)

extension Mach.Message.Header {
    /// The configuration bits in a message header.
    public struct Bits: RawRepresentable {
        /// The raw configuration bits.
        public var rawValue: mach_msg_bits_t {
            (self.otherBits & ~MACH_MSGH_BITS_PORTS_MASK)
                | self.remoteBits
                | self.localBits << 8
                | self.voucherBits << 16
        }
        /// Represents existing raw configuration bits.
        /// - Parameter rawValue: The raw configuration bits.
        public init(rawValue: mach_msg_bits_t) {
            self.remoteBits = rawValue & mach_msg_type_name_t(MACH_MSGH_BITS_REMOTE_MASK)
            self.localBits = (rawValue & mach_msg_type_name_t(MACH_MSGH_BITS_LOCAL_MASK)) >> 8
            self.voucherBits = (rawValue & mach_msg_type_name_t(MACH_MSGH_BITS_VOUCHER_MASK)) >> 16
            self.otherBits = rawValue & ~MACH_MSGH_BITS_PORTS_MASK
        }

        /// The raw remote port disposition.
        public var remoteBits: mach_msg_type_name_t
        /// The raw local port disposition.
        public var localBits: mach_msg_type_name_t
        /// The raw voucher port disposition.
        public var voucherBits: mach_msg_type_name_t
        /// The other configuration bits.
        public var otherBits: UInt32
    }
}

extension Mach.Message.Header.Bits {
    /// Whether the message is complex.
    public var isMessageComplex: Bool {
        get { self.otherBits & MACH_MSGH_BITS_COMPLEX != 0 }
        set {
            if newValue {
                self.otherBits |= MACH_MSGH_BITS_COMPLEX
            } else {
                self.otherBits &= ~MACH_MSGH_BITS_COMPLEX
            }
        }
    }
}
