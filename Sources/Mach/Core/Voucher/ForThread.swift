import Darwin.Mach

extension Mach.Thread {
    /// Sets the voucher for the thread.
    public func setVoucher(_ voucher: Mach.Voucher) throws {
        try Mach.call(thread_set_mach_voucher(self.name, voucher.name))
    }

    /// Gets the voucher for the thread.
    public func getVoucher() throws -> Mach.Voucher {
        var voucherName: mach_voucher_name_t = MACH_VOUCHER_NAME_NULL
        try Mach.call(thread_get_mach_voucher(self.name, 0, &voucherName))  // the second parameter is no longer used
        return Mach.Voucher(named: voucherName)
    }

    /// Sets the voucher for the thread and returns the previously-set voucher.
    public func swapVoucher(_ voucher: Mach.Voucher) throws -> Mach.Voucher {
        var voucherName: mach_voucher_name_t = MACH_VOUCHER_NAME_NULL
        try Mach.call(thread_swap_mach_voucher(self.name, voucher.name, &voucherName))
        return Mach.Voucher(named: voucherName)
    }
}
