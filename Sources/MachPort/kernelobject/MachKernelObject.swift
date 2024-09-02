import MachO

/// A kernel object underlying a port.
public class MachKernelObject {
    /// The type of the kernel object.
    public let type: MachKernelObjectType
    /// The address of the kernel object.
    public let address: mach_vm_address_t
    /// A description of the kernel object.
    public let description: String
    /// Get a kernel object from a port.
    /// - Parameter port: The port.
    public convenience init?(port: MachPort) {
        self.init(rawPort: port.rawValue, rawTask: port.task.rawValue)
    }

    /// Get a kernel object from a raw port and task.
    /// - Parameters:
    ///   - rawPort: The raw port.
    ///   - rawTask: The raw task that the port is in.
    public init?(rawPort: mach_port_t, rawTask: task_t) {
        var type = natural_t()
        var address = mach_vm_address_t()
        let descriptionPointer = UnsafeMutablePointer<CChar>.allocate(
            capacity: Int(KOBJECT_DESCRIPTION_LENGTH)
        )
        let ret = mach_port_kobject_description(
            rawTask, rawPort, &type, &address, descriptionPointer
        )
        guard ret == KERN_SUCCESS else { return nil }
        self.type = MachKernelObjectType(rawValue: type) ?? .unknown
        self.address = address
        self.description = String(cString: descriptionPointer)
    }
}
