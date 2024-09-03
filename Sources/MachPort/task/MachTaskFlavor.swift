import CCompat
import Darwin.Mach

/// A flavor of task.
public enum MachTaskFlavor: mach_task_flavor_t, CBinIntMacroEnum {
    case control = 0
    case read = 1
    case inspect = 2
    case name = 3
    public var cMacroName: String {
        "TASK_FLAVOR_"
            + "\(self)"
            .replacingOccurrences(
                of: "([a-z])([A-Z])", with: "$1_$2", options: .regularExpression
            )
            .uppercased()
    }
}
