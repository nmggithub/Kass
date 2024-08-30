import CCompat
import Darwin

public enum KernelObjectType: natural_t, CBinIntMacroEnum {
    case none = 0
    case threadControl = 1
    case taskControl = 2
    case host = 3
    case hostPriv = 4
    case processor = 5
    case pset = 6
    case pset_name = 7
    case timer = 8
    case portSubstOnce = 9
    case mig = 10  // not used
    case memoryObject = 11
    case xmmPager = 12  // not used
    case xmmKernel = 13  // not used
    case xmmReply = 14  // not used
    case undReply = 15
    case hostNotify = 16  // not used
    case hostSecurity = 17  // not used
    case ledger = 18  // not used
    case mainDevice = 19
    case taskName = 20
    case subsystem = 21  // not used
    case ioDoneQueue = 22  // not used
    case semaphore = 23
    case lockSet = 24  // not used
    case clock = 25
    case clockCtrl = 26  // not used
    case iokitIdent = 27
    case namedEntry = 28
    case iokitConnect = 29
    case iokitObject = 30
    case upl = 31  // not used
    case memObjControl = 32  // not used
    case auSessionport = 33
    case fileport = 34
    case labelh = 35  // not used
    case taskResume = 36
    case voucher = 37
    case voucherAttrControl = 38  // not used
    case workInterval = 39
    case uxHandler = 40
    case uextObject = 41
    case arcadeReg = 42
    case eventLink = 43
    case taskInspect = 44
    case taskRead = 45
    case threadInspect = 46
    case threadRead = 47
    case suidCred = 48  // not used
    case hypervisor = 49
    case taskIdToken = 50
    case taskFatal = 51
    case kcdata = 52
    case exclavesResource = 53
    case unknown
    public var cMacroName: String {
        "IKOT_"
            + "\(self)".replacingOccurrences(
                of: "([a-z])([A-Z])", with: "$1_$2", options: .regularExpression
            ).uppercased()
    }
}
