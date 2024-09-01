import CCompat
import MachO

/// A wrapper for a special non-allocatable and non-constructable Mach port.
/// - Warning: Do not use this class directly. Instead, use one of its subclasses.
open class MachSpecialPort: MachPortImpl {
    @available(*, unavailable, message: "Special ports cannot be allocated.")
    override public init?(
        right: Right, name: mach_port_name_t? = nil, in task: MachTask = .current
    ) { nil }
    @available(*, unavailable, message: "Special ports cannot be constructed.")
    override public init?(
        queueLimit: mach_port_msgcount_t, flags: COptionMacroSet<ConstructFlag>,
        context: mach_port_context_t = 0,
        name: mach_port_name_t? = nil,
        in task: MachTask = .current
    ) { nil }
    public required init(nilLiteral: ()) { super.init(nilLiteral: ()) }
    public required init(rawValue: mach_port_t) { super.init(rawValue: rawValue) }
}
