import CCompat
import MachO

/// A Mach voucher attribute command.
public protocol MachVoucherAttrCommand: RawRepresentable<mach_voucher_attr_command_t>,
    COptionMacroEnum
{}

/// A Mach voucher attribute command for the .bank key.
public enum BankAction: bank_action_t, MachVoucherAttrCommand {

    case originatorPid = 1
    case personaToken = 2
    case personaId = 3
    case personaAdoptAny = 4
    case originatorProximatePid = 5

    public var cMacroName: String {
        "BANK_"
            + "\(self)".replacingOccurrences(
                of: "([a-z])([A-Z])", with: "$1_$2", options: .regularExpression
            ).uppercased()
    }
}

/// A Mach voucher attribute command for the .importance key.
public enum ImportanceAction: mach_voucher_attr_importance_refs, MachVoucherAttrCommand {
    case addExternal = 1  // not supported
    case dropExternal = 2

    public var cMacroName: String {
        "MACH_VOUCHER_IMPORTANCE_ATTR_"
            + "\(self)".replacingOccurrences(
                of: "([a-z])([A-Z])", with: "$1_$2", options: .regularExpression
            ).uppercased()
    }
}
