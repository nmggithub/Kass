import Darwin.Mach

/// Port extensions.
extension Mach.Port {
    /// A way to get a right from a port.
    public enum Disposition: mach_msg_type_name_t {
        case none = 0
        case moveReceive = 16
        case moveSend = 17
        case moveSendOnce = 18
        case copySend = 19
        case makeSend = 20
        case makeSendOnce = 21
        case copyReceive = 22
        case disposeReceive = 24
        case disposeSend = 25
        case disposeSendOnce = 26
    }
}

extension Mach.Message.Header.Bits {
    /// The remote port disposition.
    public var remotePortDisposition: Mach.Port.Disposition? {
        get { Mach.Port.Disposition(rawValue: self.remoteBits) }
        set {
            guard let newDisposition = newValue else { return }
            self.remoteBits = newDisposition.rawValue
        }
    }
    /// The local port disposition.
    public var localPortDisposition: Mach.Port.Disposition? {
        get { Mach.Port.Disposition(rawValue: self.localBits) }
        set {
            guard let newDisposition = newValue else { return }
            self.localBits = newDisposition.rawValue
        }
    }
    /// The voucher port disposition.
    public var voucherPortDisposition: Mach.Port.Disposition? {
        get { Mach.Port.Disposition(rawValue: self.voucherBits) }
        set {
            guard let newDisposition = newValue else { return }
            self.voucherBits = newDisposition.rawValue
        }
    }
}
