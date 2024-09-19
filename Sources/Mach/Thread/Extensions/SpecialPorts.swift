import Darwin.Mach

extension Mach.Thread {
    /// A special port of a thread.
    public enum SpecialPort: task_special_port_t {
        case kernel = 1
        case inspect = 2
        case read = 3
    }
    /// The special ports of the thread.
    public var specialPorts: Mach.Port.SpecialPortManager<Mach.Thread, SpecialPort> {
        Mach.Port.SpecialPortManager(
            parentPort: self,
            getter: {
                thread, specialPort, portName in
                thread_get_special_port(thread.name, specialPort.rawValue, &portName)
            },
            setter: {
                thread, specialPort, portName in
                thread_set_special_port(thread.name, specialPort.rawValue, portName)
            }
        )
    }
}
