import Darwin.Mach
@_exported import MachCore

extension Mach {
    /// Virtual memory operations.
    public struct VM: Namespace {
        /// A protection value for virtual memory.
        public enum Protection: vm_prot_t {
            /// - Important: This case has no effect when used with other protection values.
            case none = 0x00
            case read = 0x01
            case write = 0x02
            case execute = 0x04
        }
    }
}
