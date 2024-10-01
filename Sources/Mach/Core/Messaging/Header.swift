import Darwin.Mach

private let MACH_MSGH_BITS_PORTS_MASK = UInt32(
    MACH_MSGH_BITS_REMOTE_MASK | MACH_MSGH_BITS_LOCAL_MASK | MACH_MSGH_BITS_VOUCHER_MASK
)

extension Mach {
    /// Configuration bits in a message header.
    public struct MessageHeaderBits: RawRepresentable {
        /// The raw configuration bits.
        public var rawValue: mach_msg_bits_t

        /// Represents existing configuration bits.
        public init(rawValue: mach_msg_bits_t) { self.rawValue = rawValue }

        /// The disposition to apply to the remote port.
        public var remotePortDisposition: Mach.PortDisposition {
            get {
                Mach.PortDisposition(
                    rawValue: mach_msg_type_name_t(
                        self.rawValue & mach_msg_type_name_t(MACH_MSGH_BITS_REMOTE_MASK)
                    )
                )
            }
            set {
                self.rawValue =
                    (self.rawValue & ~mach_msg_type_name_t(MACH_MSGH_BITS_REMOTE_MASK))
                    | newValue.rawValue & mach_msg_type_name_t(MACH_MSGH_BITS_REMOTE_MASK)
            }
        }

        /// The disposition to apply to the local port.
        public var localPortDisposition: Mach.PortDisposition {
            get {
                Mach.PortDisposition(
                    rawValue: mach_msg_type_name_t(
                        (self.rawValue & mach_msg_type_name_t(MACH_MSGH_BITS_LOCAL_MASK)) >> 8
                    )
                )
            }
            set {
                self.rawValue =
                    (self.rawValue & ~mach_msg_type_name_t(MACH_MSGH_BITS_LOCAL_MASK))
                    | (newValue.rawValue << 8) & mach_msg_type_name_t(MACH_MSGH_BITS_LOCAL_MASK)
            }
        }

        /// The disposition to apply to the voucher port.
        public var voucherPortDisposition: Mach.PortDisposition {
            get {
                Mach.PortDisposition(
                    rawValue: mach_msg_type_name_t(
                        (self.rawValue & mach_msg_type_name_t(MACH_MSGH_BITS_VOUCHER_MASK)) >> 16
                    )
                )
            }
            set {
                self.rawValue =
                    (self.rawValue & ~mach_msg_type_name_t(MACH_MSGH_BITS_VOUCHER_MASK))
                    | (newValue.rawValue << 16) & mach_msg_type_name_t(MACH_MSGH_BITS_VOUCHER_MASK)
            }
        }

        /// The other configuration bits.
        public var otherBits: UInt32 {
            get { UInt32(self.rawValue & ~MACH_MSGH_BITS_PORTS_MASK) }
            set {
                self.rawValue =
                    (self.rawValue & MACH_MSGH_BITS_PORTS_MASK)
                    | mach_msg_bits_t(newValue & ~MACH_MSGH_BITS_PORTS_MASK)
            }
        }

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
}

/// A message header.
extension mach_msg_header_t {
    /// The configuration bits.
    public var bits: Mach.MessageHeaderBits {
        get { Mach.MessageHeaderBits(rawValue: self.msgh_bits) }
        set { self.msgh_bits = newValue.rawValue }
    }

    /// The remote port.
    public var remotePort: Mach.Port {
        get { Mach.Port(named: self.msgh_remote_port) }
        set { self.msgh_remote_port = newValue.name }
    }

    /// The local port.
    public var localPort: Mach.Port {
        get { Mach.Port(named: self.msgh_local_port) }
        set { self.msgh_local_port = newValue.name }
    }

    /// The voucher port.
    public var voucherPort: Mach.Port {
        get { Mach.Port(named: self.msgh_voucher_port) }
        set { self.msgh_voucher_port = newValue.name }
    }
}
