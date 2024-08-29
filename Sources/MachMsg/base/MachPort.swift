import CCompat
import Darwin

/// A Mach port.
open class MachPort: RawRepresentable {
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
    // /// Initialize a new Mach port.
    // /// - Parameters:
    // ///   - port: The port.
    // ///   - disposition: The disposition of the port.
    // public init(port: mach_port_t, disposition: Disposition) {
    //     self.port = port
    //     self.disposition = disposition
    // }
}
