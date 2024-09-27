import Darwin.Mach

extension Mach.Message.Header.Bits {
    /// The remote port disposition.
    public var remotePortDisposition: Mach.PortDisposition? {
        get { Mach.PortDisposition(rawValue: self.remoteBits) }
        set {
            guard let newDisposition = newValue else { return }
            self.remoteBits = newDisposition.rawValue
        }
    }
    /// The local port disposition.
    public var localPortDisposition: Mach.PortDisposition? {
        get { Mach.PortDisposition(rawValue: self.localBits) }
        set {
            guard let newDisposition = newValue else { return }
            self.localBits = newDisposition.rawValue
        }
    }
    /// The voucher port disposition.
    public var voucherPortDisposition: Mach.PortDisposition? {
        get { Mach.PortDisposition(rawValue: self.voucherBits) }
        set {
            guard let newDisposition = newValue else { return }
            self.voucherBits = newDisposition.rawValue
        }
    }
}
