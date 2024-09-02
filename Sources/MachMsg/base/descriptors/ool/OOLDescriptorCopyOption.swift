import CCompat
import MachO

/// A copy option.
public enum OOLDescriptorCopyOption: mach_msg_copy_options_t, CBinIntMacroEnum {
    /// - Warning: This value is not a valid copy option. It is only used to represent an unknown copy option.
    case unknown = 0xFFFF_FFFF
    case physical = 0
    case virtual = 1
    case allocate = 2
    case overwrite = 3  // deprecated
    case kallocCopy = 4  // kernel only
    public var cMacroName: String {
        switch self {
        case .physical: "MACH_MSG_PHYSICAL_COPY"
        case .virtual: "MACH_MSG_VIRTUAL_COPY"
        case .allocate: "MACH_MSG_ALLOCATE"
        case .overwrite: "MACH_MSG_OVERWRITE"
        case .kallocCopy: "MACH_MSG_KALLOC_COPY_T"
        case .unknown: ""
        }
    }
}
