import Darwin

/// A kernel object underlying a Mach port.
public class KernelObject {
    /// The type of the kernel object.
    public let type: KernelObjectType
    /// The address of the kernel object.
    public let address: mach_vm_address_t
    /// A description of the kernel object.
    public let description: String
    /// Creates a kernel object from a Mach port.
    /// - Parameter port: The Mach port.
    public init?(port: MachPort) {
        var type = natural_t()
        var address = mach_vm_address_t()
        let descriptionPointer = UnsafeMutablePointer<CChar>.allocate(
            capacity: Int(KOBJECT_DESCRIPTION_LENGTH)
        )
        let ret = mach_port_kobject_description(
            mach_task_self_, port.rawValue, &type, &address, descriptionPointer)
        guard ret == KERN_SUCCESS else { return nil }
        self.type = KernelObjectType(rawValue: type) ?? .unknown
        self.address = address
        self.description = String(cString: descriptionPointer)
    }
}
