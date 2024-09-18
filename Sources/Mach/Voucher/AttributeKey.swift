import Darwin.Mach

extension Mach.Voucher {
    /// A voucher attribute key.
    public enum AttributeKey: mach_voucher_attr_key_t {
        case all = 0xFFFF_FFFF
        case none = 0
        case atm = 1
        case importance = 2
        case bank = 3
        case pthpriority = 4
        // Where are 5 and 6?
        case userData = 7  // also known as `bits`, but we can't have duplicate cases
        case test = 8
    }
}
