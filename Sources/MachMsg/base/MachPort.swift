import CCompat
import Darwin

/// A Mach port.
open class MachPort: RawRepresentable {
    public enum Right: mach_port_right_t, CBinIntMacroEnum {
        case unknown = 0xFFFF_FFFF
        case send = 0
        case receive = 1
        case sendOnce = 2
        case portSet = 3
        case deadName = 4
        case labelh = 5
        case number = 6
        public var cMacroName: String {
            "MACH_PORT_RIGHT_"
                + "\(self)"
                .replacingOccurrences(
                    of: "([a-z])([A-Z])", with: "$1_$2", options: .regularExpression
                )
                .uppercased()
        }
        public init(fromType type: mach_port_type_t) {
            self = Self(rawValue: mach_port_right_t(log2(Double(type)) - 16)) ?? .unknown
        }
    }
    public var right: Right {
        var type = mach_port_type_t()
        let ret = mach_port_type(mach_task_self_, self.rawValue, &type)
        guard ret == KERN_SUCCESS else { return .unknown }
        return Right(fromType: type)
    }
    /// A null Mach port.
    public static var null: Self {
        Self(rawValue: mach_port_t(MACH_PORT_NULL))
    }
    /// The raw Mach port.
    public var rawValue: mach_port_t
    /// Initialize a new Mach port with the given raw port.
    public required init(rawValue: mach_port_t) {
        self.rawValue = rawValue
    }
    /// Initialize a new Mach port.
    public convenience init() {
        self.init(rawValue: mach_port_t(MACH_PORT_NULL))
    }
    public static var all: [MachPort] {
        var namesCount = mach_msg_type_number_t.max
        var names: mach_port_name_array_t? = mach_port_name_array_t.allocate(
            capacity: Int(namesCount)
        )
        // the types array is not used, but it is required by `mach_port_names`
        var typesCount = mach_msg_type_number_t.max
        var types: mach_port_type_array_t? = mach_port_type_array_t.allocate(
            capacity: Int(typesCount)
        )
        let ret = mach_port_names(mach_task_self_, &names, &namesCount, &types, &typesCount)
        guard ret == KERN_SUCCESS else { return [] }
        return (0..<Int(namesCount)).map { MachPort(rawValue: names![$0]) }
    }
}
