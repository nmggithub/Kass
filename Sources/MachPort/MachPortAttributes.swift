import CCompat
import MachO

/// An attribute of a port.
public enum MachPortAttribute: mach_port_flavor_t, CBinIntMacroEnum {
    case limitsInfo = 1
    case receiveStatus = 2
    case dnrequestsSize = 3
    case tempowner = 4
    case importanceReceiver = 5
    case denapReceiver = 6
    case infoExt = 7
    case guardInfo = 8
    case serviceThrottled = 9
    public var cMacroName: String {
        "MACH_PORT_"
            + "\(self)"
            .replacingOccurrences(
                of: "([a-z])([A-Z])", with: "$1_$2", options: .regularExpression
            )
            .uppercased()
    }
}

/// The attributes of the port.
public struct MachPortAttributes {
    internal let port: any MachPort
    public subscript<T>(flavor: MachPortAttribute, as: T.Type) -> T? {
        get {
            var count = mach_msg_type_number_t.max
            let info = mach_port_info_t.allocate(capacity: Int(count))
            let ret = mach_port_get_attributes(
                self.port.task.rawValue, self.port.rawValue, flavor.rawValue, info, &count
            )
            guard ret == KERN_SUCCESS else { return nil }
            return info.withMemoryRebound(to: T.self, capacity: Int(count)) { $0.pointee }
        }
        set(newValue) {
            guard newValue != nil else { return }
            // The kernel will return `MIG_ARRAY_TOO_LARGE` if the count is too large.
            let count = mach_msg_type_number_t(0x11)
            let info = mach_port_info_t.allocate(capacity: Int(count))
            info.withMemoryRebound(to: T.self, capacity: Int(count)) { $0.pointee = newValue! }
            let ret = mach_port_set_attributes(
                self.port.task.rawValue, self.port.rawValue, flavor.rawValue, info, count
            )
            guard ret == KERN_SUCCESS else { return }
        }
    }
}
