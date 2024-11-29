import Darwin.Mach

extension Mach.Thread {
    /// The thread's voucher.
    public var voucher: Mach.Voucher {
        get throws {
            var voucherName: mach_voucher_name_t = MACH_VOUCHER_NAME_NULL
            try Mach.call(thread_get_mach_voucher(self.name, 0, &voucherName))  // the second parameter is no longer used
            return Mach.Voucher(named: voucherName)
        }
    }

    /// Sets the thread's voucher.
    public func setVoucher(_ voucher: Mach.Voucher) throws {
        try Mach.call(thread_set_mach_voucher(self.name, voucher.name))
    }

    /// Swaps the thread's voucher with another.
    /// - Returns: The old voucher.
    public func swapVoucher(with voucher: Mach.Voucher) throws -> Mach.Voucher {
        var voucherName: mach_voucher_name_t = MACH_VOUCHER_NAME_NULL
        try Mach.call(thread_swap_mach_voucher(self.name, voucher.name, &voucherName))
        return Mach.Voucher(named: voucherName)
    }
}
