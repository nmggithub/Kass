import Darwin.Mach
import MachBase

extension Mach.Thread {
    /// Sets the voucher for the thread.
    /// - Parameter voucher: The voucher to set.
    /// - Throws: An error if the voucher could not be set.
    public func setVoucher(_ voucher: Mach.Voucher) throws {
        try Mach.call(thread_set_mach_voucher(self.name, voucher.name))
    }
    /// Gets the voucher for the thread.
    /// - Throws: An error if the voucher could not be retrieved.
    /// - Returns: The voucher.
    public func getVoucher() throws -> Mach.Voucher {
        var voucherName: mach_voucher_name_t = MACH_VOUCHER_NAME_NULL
        try Mach.call(thread_get_mach_voucher(self.name, 0, &voucherName))  // the second parameter is no longer used
        return Mach.Voucher(named: voucherName)
    }
    /// Swaps the voucher for the thread.
    /// - Parameter voucher: The new voucher.
    /// - Throws: An error if the voucher could not be swapped.
    /// - Returns: The old voucher.
    public func swapVoucher(_ voucher: Mach.Voucher) throws -> Mach.Voucher {
        var voucherName: mach_voucher_name_t = MACH_VOUCHER_NAME_NULL
        try Mach.call(thread_swap_mach_voucher(self.name, voucher.name, &voucherName))
        return Mach.Voucher(named: voucherName)
    }
}
