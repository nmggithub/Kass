import Darwin.Mach

/// A kernel object.
typealias MachKernelObject = Mach.KernelObject

extension Mach {
    /// A kernel object.
    public struct KernelObject {
        /// A type of kernel object.
        public enum ObjectType: natural_t {
            case none = 0
            case threadControl = 1
            case taskControl = 2
            case host = 3
            case hostPriv = 4
            case processor = 5
            case pset = 6
            case psetName = 7
            case timer = 8
            case portSubstOnce = 9
            // @available(
            //     *, deprecated, message: "This kernel object type is commented out in the kernel."
            // )
            case mig = 10
            case memoryObject = 11
            // @available(
            //     *, deprecated, message: "This kernel object type is commented out in the kernel."
            // )
            case xmmPager = 12
            // @available(
            //     *, deprecated, message: "This kernel object type is commented out in the kernel."
            // )
            case xmmKernel = 13
            // @available(
            //     *, deprecated, message: "This kernel object type is commented out in the kernel."
            // )
            case xmmReply = 14
            case undReply = 15
            // @available(
            //     *, deprecated, message: "This kernel object type is commented out in the kernel."
            // )
            case hostNotify = 16
            // @available(
            //     *, deprecated, message: "This kernel object type is commented out in the kernel."
            // )
            case hostSecurity = 17
            // @available(
            //     *, deprecated, message: "This kernel object type is commented out in the kernel."
            // )
            case ledger = 18
            case mainDevice = 19
            case taskName = 20
            // @available(
            //     *, deprecated, message: "This kernel object type is commented out in the kernel."
            // )
            case subsystem = 21
            // @available(
            //     *, deprecated, message: "This kernel object type is commented out in the kernel."
            // )
            case ioDoneQueue = 22
            case semaphore = 23
            // @available(
            //     *, deprecated, message: "This kernel object type is commented out in the kernel."
            // )
            case lockSet = 24
            case clock = 25
            // @available(
            //     *, deprecated, message: "This kernel object type is commented out in the kernel."
            // )
            case clockCtrl = 26
            case iokitIdent = 27
            case namedEntry = 28
            case iokitConnect = 29
            case iokitObject = 30
            // @available(
            //     *, deprecated, message: "This kernel object type is commented out in the kernel."
            // )
            case upl = 31
            // @available(
            //     *, deprecated, message: "This kernel object type is commented out in the kernel."
            // )
            case memObjControl = 32
            case auSessionport = 33
            case fileport = 34
            // @available(
            //     *, deprecated, message: "This kernel object type is commented out in the kernel."
            // )
            case labelh = 35
            case taskResume = 36
            case voucher = 37
            // @available(
            //     *, deprecated, message: "This kernel object type is commented out in the kernel."
            // )
            case voucherAttrControl = 38
            case workInterval = 39
            case uxHandler = 40
            case uextObject = 41
            case arcadeReg = 42
            case eventLink = 43
            case taskInspect = 44
            case taskRead = 45
            case threadInspect = 46
            case threadRead = 47
            // @available(
            //     *, deprecated, message: "This kernel object type is commented out in the kernel."
            // )
            case suidCred = 48
            case hypervisor = 49
            case taskIdToken = 50
            case taskFatal = 51
            case kcdata = 52
            case exclavesResource = 53
            case unknown
        }
        /// The type of the kernel object.
        public let type: Mach.KernelObject.ObjectType
        /// The address of the kernel object.
        /// - Warning: When using non-development kernel builds, this address may be zero.
        public let address: mach_vm_address_t
        /// A string describing the kernel object.
        public let description: String

        /// Get the underlying kernel object for a port.
        /// - Parameter port: The port.
        /// - Throws: An error if the kernel object cannot be retrieved.
        public init(underlying port: Mach.Port) throws {
            var type = natural_t()
            var objectAddress = mach_vm_address_t()
            let descriptionPointer = UnsafeMutablePointer<CChar>.allocate(
                capacity: Int(KOBJECT_DESCRIPTION_LENGTH)
            )
            try Mach.call(
                mach_port_kobject_description(
                    port.owningTask.name, port.name, &type, &objectAddress, descriptionPointer
                )
            )
            self.type = Self.ObjectType(rawValue: type) ?? .unknown
            self.address = objectAddress
            self.description = String(cString: descriptionPointer)
        }
    }
}
