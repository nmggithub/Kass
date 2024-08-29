import CCompat
import Darwin

/// A Mach voucher attribute recipe command.
public enum MachVoucherAttrRecipeCommand: mach_voucher_attr_recipe_command_t, COptionMacroEnum {
    case noop = 0
    case copy = 1
    case remove = 2
    case setValueHandle = 3
    case autoRedeem = 4
    case sendPreprocess = 5

    case redeem = 10

    case importanceSelf = 200
    case userDataStore = 211

    case atmNull = 501
    case atmCreate = 502
    case atmRegister = 503

    case bankNull = 601
    case bankCreate = 610
    case bankModifyPersona = 611

    case pthpriorityNull = 701
    case pthpriorityCreate = 702

    public var cMacroName: String {
        "MACH_VOUCHER_ATTR_"
            + "\(self)".replacingOccurrences(
                of: "([a-z])([A-Z])", with: "$1_$2", options: .regularExpression
            )
            .uppercased()
    }
}
