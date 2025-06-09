import Darwin.Mach
import KassC.Compat
import KassC.IPCKobject

/// A type of kernel object.
/// - Warning: This work is covered under license. Please view the source code and <doc:MachCore#Licenses> for more information.
extension ipc_kotype_t {
    /// There is no kernel object.
    public static let none = Self.IKOT_NONE

    /// The port is a thread control port.
    public static let threadControl = Self.IKOT_THREAD_CONTROL

    /// The port is a task control port.
    public static let taskControl = Self.IKOT_TASK_CONTROL

    /// The port is a host control port.
    public static let host = Self.IKOT_HOST

    /// The port is a privileged host port.
    public static let hostPriv = Self.IKOT_HOST_PRIV

    /// A processor.
    public static let processor = Self.IKOT_PROCESSOR

    /// The port is a processor set control port.
    public static let pset = Self.IKOT_PSET

    /// The port is a processor set name port.
    public static let psetName = Self.IKOT_PSET_NAME

    /// A timer.
    public static let timer = Self.IKOT_TIMER

    /// The port is a substitute-once port.
    public static let substituteOnce = Self.IKOT_PORT_SUBST_ONCE

    /// A MIG object.
    @available(macOS, obsoleted: 12.0.1)
    public static let mig = Self.IKOT_MIG

    /// A memory object.
    public static let memoryObject = Self.IKOT_MEMORY_OBJECT

    /// A XMM pager.
    @available(macOS, obsoleted: 12.0.1)
    public static let xmmPager = Self.IKOT_XMM_PAGER

    /// A XMM kernel.
    @available(macOS, obsoleted: 12.0.1)
    public static let xmmKernel = Self.IKOT_XMM_KERNEL

    /// A XMM reply.
    @available(macOS, obsoleted: 12.0.1)
    public static let xmmReply = Self.IKOT_XMM_REPLY

    /// A user-notification daemon reply.
    public static let undReply = Self.IKOT_UND_REPLY

    /// The port is a host notification port.
    @available(macOS, obsoleted: 13.0)
    public static let hostNotify = Self.IKOT_HOST_NOTIFY

    /// The port is a host security port.
    @available(macOS, obsoleted: 12.0.1)
    public static let hostSecurity = Self.IKOT_HOST_SECURITY

    /// A ledger.
    @available(macOS, obsoleted: 12.0.1)
    public static let ledger = Self.IKOT_LEDGER

    /// An IOKit main device service.
    public static let mainDevice = Self.IKOT_MAIN_DEVICE

    /// The port is a task name port.
    public static let taskName = Self.IKOT_TASK_NAME

    /// A subsystem.
    @available(macOS, obsoleted: 12.0.1)
    public static let subsystem = Self.IKOT_SUBSYSTEM

    /// An IOKit done queue.
    @available(macOS, obsoleted: 12.0.1)
    public static let ioDoneQueue = Self.IKOT_IO_DONE_QUEUE

    /// A semaphore.
    public static let semaphore = Self.IKOT_SEMAPHORE

    /// A lock set.
    @available(macOS, obsoleted: 12.0.1)
    public static let lockSet = Self.IKOT_LOCK_SET

    /// The port is a clock port.
    public static let clock = Self.IKOT_CLOCK

    /// The port is a clock control port.
    @available(macOS, obsoleted: 13.0)
    public static let clockCtrl = Self.IKOT_CLOCK_CTRL

    /// An IOKit server check-in token.
    public static let iokitIdent = Self.IKOT_IOKIT_IDENT

    /// A memory entry.
    public static let memoryEntry = Self.IKOT_NAMED_ENTRY

    /// An IOKit connection.
    public static let iokitConnect = Self.IKOT_IOKIT_CONNECT

    /// An IOKit object.
    public static let iokitObject = Self.IKOT_IOKIT_OBJECT

    /// A universal page list.
    @available(macOS, obsoleted: 12.0.1)
    public static let upl = Self.IKOT_UPL

    /// The port is a memory object control port.
    /// - Note: Technically, this kernel object type existed in macOS 12.0.1, but it was only used in one check. That check specifically
    /// would intentionally kernel panic if it encountered this type, so it's safe to say that this type was obsoleted in macOS 12.0.1.
    @available(macOS, obsoleted: 12.0.1)
    public static let memObjControl = Self.IKOT_MEM_OBJ_CONTROL

    /// An audit session.
    public static let auditSession = Self.IKOT_AU_SESSIONPORT

    /// A fileport (file descriptor).
    public static let fileport = Self.IKOT_FILEPORT

    /// A task resume token.
    public static let taskResume = Self.IKOT_TASK_RESUME

    /// A voucher.
    public static let voucher = Self.IKOT_VOUCHER

    /// The port is a voucher attribute control port.
    @available(macOS, obsoleted: 13)
    public static let voucherAttrControl = Self.IKOT_VOUCHER_ATTR_CONTROL

    /// A work interval.
    public static let workInterval = Self.IKOT_WORK_INTERVAL

    /// A user exception handler.
    public static let uxHandler = Self.IKOT_UX_HANDLER

    /// An OSObject used in IOKit.
    public static let uextObject = Self.IKOT_UEXT_OBJECT

    /// A register for Apple Arcade.
    public static let arcadeRegister = Self.IKOT_ARCADE_REG

    /// An eventlink.
    public static let eventlink = Self.IKOT_EVENTLINK

    /// The port is a task inspect port.
    public static let taskInspect = Self.IKOT_TASK_INSPECT

    /// The port is a task read port.
    public static let taskRead = Self.IKOT_TASK_READ

    /// The port is a thread inspect port.
    public static let threadInspect = Self.IKOT_THREAD_INSPECT

    /// The port is a thread read port.
    public static let threadRead = Self.IKOT_THREAD_READ

    /// A setuid credential.
    @available(macOS, obsoleted: 12.3)
    public static let setuidCredential = Self.IKOT_SUID_CRED

    /// A hypervisor.
    public static let hypervisor = Self.IKOT_HYPERVISOR

    /// A task identity token.
    public static let taskIdentityToken = Self.IKOT_TASK_ID_TOKEN

    /// The port is a task fatal port.
    public static let taskFatal = Self.IKOT_TASK_FATAL

    /// Kernelcache data.
    public static let kcdata = Self.IKOT_KCDATA

    /// An exclaves resource.
    public static let exclavesResource = Self.IKOT_EXCLAVES_RESOURCE

    /// The type of the kernel object is unknown.
    public static let unknown = Self.IKOT_UNKNOWN
}

extension ipc_kotype_t: @retroactive CustomStringConvertible {
    public var description: String {
        switch self {
        case .none: return "None"
        case .threadControl: return "Thread Control"
        case .taskControl: return "Task Control"
        case .host: return "Host"
        case .hostPriv: return "Privileged Host"
        case .processor: return "Processor"
        case .pset: return "Processor Set Control"
        case .psetName: return "Processor Set Name"
        case .timer: return "Timer"
        case .substituteOnce: return "Substitute-Once Port"
        case .mig: return "MIG"
        case .memoryObject: return "Memory Object"
        case .xmmPager: return "XMM Pager"
        case .xmmKernel: return "XMM Kernel"
        case .xmmReply: return "XMM Reply"
        case .undReply: return "User-Notification Daemon Reply"
        case .hostNotify: return "Host Notification"
        case .hostSecurity: return "Host Security"
        case .ledger: return "Ledger"
        case .mainDevice: return "Main Device"
        case .taskName: return "Task Name"
        case .subsystem: return "Subsystem"
        case .ioDoneQueue: return "IOKit Done Queue"
        case .semaphore: return "Semaphore"
        case .lockSet: return "Lock Set"
        case .clock: return "Clock"
        case .clockCtrl: return "Clock Control"
        case .iokitIdent: return "IOKit Check-In Token"
        case .memoryEntry: return "Memory Entry"
        case .iokitConnect: return "IOKit Connection"
        case .iokitObject: return "IOKit Object"
        case .upl: return "Universal Page List"
        case .memObjControl: return "Memory Object Control"
        case .auditSession: return "Audit Session"
        case .fileport: return "Fileport"
        case .taskResume: return "Task Resume"
        case .voucher: return "Voucher"
        case .voucherAttrControl: return "Voucher Attribute Control"
        case .workInterval: return "Work Interval"
        case .uxHandler: return "User Exception Handler"
        case .uextObject: return "UEXT Object"
        case .arcadeRegister: return "Arcade Register"
        case .eventlink: return "Event Link"
        case .taskInspect: return "Task Inspect"
        case .taskRead: return "Task Read"
        case .threadInspect: return "Thread Inspect"
        case .threadRead: return "Thread Read"
        case .setuidCredential: return "Setuid Credential"
        case .hypervisor: return "Hypervisor"
        case .taskIdentityToken: return "Task Identity Token"
        case .taskFatal: return "Task Fatal"
        case .kcdata: return "Kernelcache Data"
        case .exclavesResource: return "Exclaves Resource"
        case .unknown: return "Unknown"
        default: return "Unknown"
        }
    }
}

extension Mach {
    /// A kernel object underlying a port.
    public struct KernelObject {
        /// The type of the kernel object.
        public let type: ipc_kotype_t

        /// The address of the kernel object.
        /// - Warning: When using non-development kernel builds, this address may be zero.
        public let address: mach_vm_address_t

        /// A string describing the kernel object.
        public let description: String

        /// Gets the underlying kernel object for a port.
        public init(underlying port: Mach.Port) throws {
            var type = natural_t()
            var objectAddress = mach_vm_address_t()
            let descriptionPointer = UnsafeMutablePointer<CChar>.allocate(
                capacity: Int(KOBJECT_DESCRIPTION_LENGTH)
            )
            try Mach.call(
                mach_port_kobject_description_compat(
                    port.owningTask.name, port.name, &type, &objectAddress, descriptionPointer
                )
            )
            self.type = ipc_kotype_t(rawValue: type) ?? .unknown
            self.address = objectAddress
            self.description = String(cString: descriptionPointer)
        }
    }
}
