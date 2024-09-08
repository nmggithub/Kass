import Darwin.Mach
import MachBase
import MachPort

extension Mach.Task {
    public enum SpecialPort: task_special_port_t {
        case kernel = 1
        case host = 2
        case name = 3
        case bootstrap = 4
        case inspection = 5
        case read = 6
        // @available(
        //     *, deprecated, message: "This task special port type is commented out in the kernel."
        // )
        case seatbelt = 7
        // @available(
        //     *, deprecated, message: "This task special port type is commented out in the kernel."
        // )
        case gssd = 8
        case access = 9
        case debugControl = 10
        case resourceNotify = 11
    }
    public var specialPorts: Mach.Port.SpecialPortManager<Mach.Task, SpecialPort> {
        Mach.Port.SpecialPortManager(
            parentPort: self,
            getter: {
                task, specialPort, portName in
                task_get_special_port(task.name, specialPort.rawValue, &portName)
            },
            setter: {
                task, specialPort, portName in
                task_set_special_port(task.name, specialPort.rawValue, portName)
            }
        )
    }
}
