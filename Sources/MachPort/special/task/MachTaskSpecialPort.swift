import CCompat
import Darwin.Mach

/// A type of special port for a task.
public enum MachTaskSpecialPortType: task_special_port_t, CBinIntMacroEnum {
    case kernel = 1
    case host = 2
    case name = 3
    case bootstrap = 4
    case inspection = 5
    case read = 6
    @available(
        *, deprecated, message: "This task special port type is commented out in the kernel."
    )
    case seatbelt = 7  // not used
    @available(
        *, deprecated, message: "This task special port type is commented out in the kernel."
    )
    case gssd = 8  // not used
    case access = 9
    case debugControl = 10
    case resourceNotify = 11
    public var cMacroName: String {
        "TASK_"
            + "\(self)"
            .replacingOccurrences(
                of: "([a-z])([A-Z])", with: "$1_$2", options: .regularExpression
            )
            .uppercased() + "_PORT"
    }
}

/// A container of special ports for a task.
/// - Important: Setting a special port is not guaranteed to succeed, and any errors from the kernel are ignored.
public struct MachTaskSpecialPorts {
    internal let task: MachTask
    /// Get or set a special port for the task.
    /// - Parameters:
    ///   - portType: The type of the special port.
    public subscript<T: MachTaskSpecialPort>(portType: MachTaskSpecialPortType,
        portClass: T.Type = MachTaskSpecialPort.self
    )
        -> T?
    {
        get {
            var rawPort = T.RawValue()
            let ret = task_get_special_port(self.task.rawValue, portType.rawValue, &rawPort)
            guard ret == KERN_SUCCESS else { return nil }
            let port = T.init(rawValue: rawPort)
            port.rawTask = self.task.rawValue
            return port
        }
        set(newValue) {
            let portToUse = newValue?.rawValue ?? T.RawValue(MACH_PORT_NULL)
            task_set_special_port(self.task.rawValue, portType.rawValue, portToUse)
        }
    }
}

/// A special port for a task.
public class MachTaskSpecialPort: MachSpecialPort {}
