import CCompat
import MachO

/// A wrapper for a special non-allocatable and non-constructable Mach port.
/// - Warning: Do not use this class directly. Instead, use one of its subclasses.
open class MachSpecialPort: MachPort {
    @available(*, unavailable, message: "Special ports cannot be allocated.")
    public override class func allocate(
        right: Right, name: mach_port_name_t? = nil, in task: MachTask = .current
    ) -> Self { Self.null }
    @available(*, unavailable, message: "Special ports cannot be constructed.")
    public override class func construct(
        queueLimit: mach_port_msgcount_t, flags: COptionMacroSet<ConstructFlag>,
        context: mach_port_context_t = 0,
        name: mach_port_name_t? = nil,
        in task: MachTask = .current
    ) -> Self { Self.null }
}
