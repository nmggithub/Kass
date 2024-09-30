import Darwin.Mach

extension Mach.Message.Header.Bits {
    /// The remote port disposition.
    public var remotePortDisposition: Mach.PortDisposition {
        get { Mach.PortDisposition(rawValue: self.remoteBits) }
        set { self.remoteBits = newValue.rawValue }
    }
    /// The local port disposition.
    public var localPortDisposition: Mach.PortDisposition {
        get { Mach.PortDisposition(rawValue: self.localBits) }
        set { self.localBits = newValue.rawValue }
    }
    /// The voucher port disposition.
    public var voucherPortDisposition: Mach.PortDisposition {
        get { Mach.PortDisposition(rawValue: self.voucherBits) }
        set { self.voucherBits = newValue.rawValue }
    }
}
