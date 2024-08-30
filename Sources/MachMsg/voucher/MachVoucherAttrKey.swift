import CCompat
import MachO

/// A Mach voucher attribute key.
public enum MachVoucherAttrKey: mach_voucher_attr_key_t, COptionMacroEnum {
    case all = 0xFFFF_FFFF
    case none = 0
    case atm = 1
    case importance = 2
    case bank = 3
    case pthpriority = 4
    // Where are 5 and 6?
    case userData = 7  // also known as `bits`, but we can't have duplicate cases
    case test = 8
    public var cMacroName: String {
        "MACH_VOUCHER_ATTR_KEY_"
            + "\(self)".replacingOccurrences(
                of: "([a-z])([A-Z])", with: "$1_$2", options: .regularExpression
            )
            .uppercased()
    }
}
