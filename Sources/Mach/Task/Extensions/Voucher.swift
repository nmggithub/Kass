import Darwin.Mach
import MachVoucher

extension Mach.Task {
    /// Sets the voucher for the task.
    public func setVoucher(_ voucher: Mach.Voucher) throws {
        try Mach.call(task_set_mach_voucher(self.name, voucher.name))
    }
    /// Gets the voucher for the task.
    public func getVoucher() throws -> Mach.Voucher {
        var voucherName: mach_voucher_name_t = MACH_VOUCHER_NAME_NULL
        try Mach.call(task_get_mach_voucher(self.name, 0, &voucherName))  // the second parameter is no longer used
        return Mach.Voucher(named: voucherName)
    }
    /// Swaps the voucher for the task.
    /// - Returns: The old voucher.
    public func swapVoucher(_ voucher: Mach.Voucher) throws -> Mach.Voucher {
        var voucherName: mach_voucher_name_t = MACH_VOUCHER_NAME_NULL
        try Mach.call(task_swap_mach_voucher(self.name, voucher.name, &voucherName))
        return Mach.Voucher(named: voucherName)
    }
}
