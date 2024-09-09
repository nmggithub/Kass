import Darwin.Mach

extension Mach.Message.Body {
    /// A copy option for OOL descriptors.
    public enum OOLDescriptorCopyOption: mach_msg_copy_options_t {
        /// - Important: This value is not a valid copy option. It is only used to represent an unknown copy option.
        case unknown = 0xFFFF_FFFF
        case physical = 0
        case virtual = 1
        case allocate = 2
        case overwrite = 3  // deprecated
        case kallocCopy = 4  // kernel only
    }
}
