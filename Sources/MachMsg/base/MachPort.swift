import CCompat
import Foundation
import MachO

/// A Mach port.
open class MachPort: RawRepresentable, Hashable {
    /// The task which the Mach port is in.
    /// - Important: This defaults to the current task. To get a port in another task, use `MachTask.ports`.
    public let task: MachTask
    /// A right for a Mach port.
    public enum Right: mach_port_right_t, CBinIntMacroEnum, CaseIterable {
        case send = 0
        case receive = 1
        case sendOnce = 2
        case portSet = 3
        case deadName = 4
        case labelh = 5
        case number = 6
        public var cMacroName: String {
            "MACH_PORT_RIGHT_"
                + "\(self)"
                .replacingOccurrences(
                    of: "([a-z])([A-Z])", with: "$1_$2", options: .regularExpression
                )
                .uppercased()
        }
    }

    /// Get the rights of a Mach port in a task.
    /// - Parameters:
    ///   - port: The Mach port.
    ///   - task: The task that the port is in.
    /// - Returns: The rights of the port.
    public static func rights(of port: mach_port_t, in task: MachTask = .current) -> Set<Right> {
        var type = mach_port_type_t()
        let ret = mach_port_type(task.rawValue, port, &type)
        guard ret == KERN_SUCCESS else { return [] }
        var rights = Set<Right>()
        for right in Right.allCases {
            // `mach_port_type_t` is a bitfield for the rights
            if type & 1 << (right.rawValue + 16) != 0 {
                rights.insert(right)
            }
        }
        return rights
    }

    /// The rights of the Mach port.
    /// - Note: Both inserting and removing rights are not guaranteed to succeed. Any errors from the Mach kernel when doing so are ignored.
    /// - Warning: Attempting to remove the `.receive` right from a guarded Mach port may crash the program.
    public var rights: Set<Right> {
        get {
            Self.rights(of: self.rawValue)
        }
        set {
            let newRights = newValue.subtracting(self.rights)
            let oldRights = self.rights.subtracting(newValue)
            for newRight in newRights {
                mach_port_insert_right(
                    self.task.rawValue, self.rawValue, self.rawValue, newRight.rawValue
                )
            }
            for oldRight in oldRights {
                var refCount = mach_port_urefs_t()
                // First, we get the current reference count for the right.
                let ret = mach_port_get_refs(
                    self.task.rawValue, self.rawValue, oldRight.rawValue, &refCount
                )
                guard ret == KERN_SUCCESS else { continue }
                // Then we decrement the reference count by the current reference count, to decrement it to zero,
                // which will deallocate the right. If the reference count somehow changes between the two calls,
                // the deallocation will fail, but there doesn't seem to be an atomic way to do this.
                mach_port_mod_refs(
                    self.task.rawValue, self.rawValue, oldRight.rawValue,
                    -mach_port_delta_t(refCount)
                )
            }
        }
    }

    /// Whether the Mach port is guarded or not.
    /// - Warning:
    ///     This is not atomic, as it requires attempting to guard the port, and then unguarding it if needed. If an unexpected error
    ///     occurs during this process, the program will deliberately crash as the port would then be in an unknown state.
    public var guarded: Bool {
        // Only ports with the `.receive` right can be guarded, so if the port does not have the `.receive` right, it is not guarded.
        guard self.rights.contains(.receive) else { return false }
        // There is no way to check if a port is guarded without attempting to guard it.
        let testGuard = mach_port_context_t()
        let guardRet = mach_port_guard(self.task.rawValue, self.rawValue, testGuard, 0)
        switch guardRet {
        // The kernel will return `KERN_INVALID_ARGUMENT` if the port is already guarded.
        case KERN_INVALID_ARGUMENT: return true
        // These errors are expected from the kernel implementation of `mach_port_guard`.
        case KERN_INVALID_TASK, KERN_INVALID_NAME, KERN_INVALID_RIGHT:
            return false
        case KERN_SUCCESS: break  // The guarding worked, so we need to unguard it.
        // The userspace implementation of `mach_port_guard` sends a Mach message to the kernel, and has its own family of
        // errors. If we get one of these errors, we need to crash the program, as the port is now in an unknown state.
        default: fatalError("Unexpected return code from `mach_port_guard`: \(guardRet)")
        }

        let unguardRet: kern_return_t = mach_port_unguard(
            self.task.rawValue, self.rawValue, testGuard)
        guard unguardRet == KERN_SUCCESS else {
            // This should hopefully never happen, but if it does, we need to crash the program, as the port is now in an unknown state.
            fatalError("Failed to unguard the port after testing if it was guarded.")
        }
        return false
    }

    /// A flag for guarding a Mach port.
    public enum GuardFlag: UInt64, COptionMacroEnum {
        case strict = 1
        case immovableReceive = 2
        public var cMacroName: String {
            "MPG_"
                + "\(self)".replacingOccurrences(
                    of: "([a-z])([A-Z])", with: "$1_$2", options: .regularExpression
                ).uppercased()
        }
    }

    /// Guard the Mach port using the given context and flags.
    /// - Parameters:
    ///   - context: The context to guard the port with.
    ///   - flags: The flags to guard the port with.
    /// - Throws: An error if the guarding fails.
    public func `guard`(context: mach_port_context_t, flags: COptionMacroSet<GuardFlag>) throws {
        let guardRet = mach_port_guard_with_flags(
            self.task.rawValue, self.rawValue, context, flags.rawValue
        )
        guard guardRet == KERN_SUCCESS else {
            throw NSError(domain: NSMachErrorDomain, code: Int(guardRet))
        }
    }

    /// Swap the guard of the Mach port from the old context to the new context.
    /// - Parameters:
    ///   - old: The old context.
    ///   - new: The new context.
    /// - Throws: An error if the swapping fails.
    public func swapGuard(old: mach_port_context_t, new: mach_port_context_t) throws {
        let swapRet = mach_port_swap_guard(
            self.task.rawValue, self.rawValue, old, new
        )
        guard swapRet == KERN_SUCCESS else {
            throw NSError(domain: NSMachErrorDomain, code: Int(swapRet))
        }
    }

    /// Unguard the Mach port using the given context.
    /// - Parameter context: The context to unguard the port with.
    /// - Throws: An error if the unguarding fails.
    public func unguard(context: mach_port_context_t) throws {
        let unguardRet = mach_port_unguard(self.task.rawValue, self.rawValue, context)
        guard unguardRet == KERN_SUCCESS else {
            throw NSError(domain: NSMachErrorDomain, code: Int(unguardRet))
        }
    }

    /// The Mach port context.
    public var context: mach_port_context_t {
        get {
            var context = mach_port_context_t()
            let ret = mach_port_get_context(self.task.rawValue, self.rawValue, &context)
            guard ret == KERN_SUCCESS else { return mach_port_context_t() }
            return context
        }
        set {
            let ret = mach_port_set_context(self.task.rawValue, self.rawValue, newValue)
            guard ret == KERN_SUCCESS else { return }
        }
    }

    public var kernelObject: KernelObject? {
        KernelObject(port: self)
    }

    /// An attribute of a Mach port.
    public enum Attribute: mach_port_flavor_t, CBinIntMacroEnum {
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

    /// The attributes of the Mach port.
    public struct Attributes {
        internal let port: MachPort
        public subscript<T>(flavor: Attribute, as: T.Type) -> T? {
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

    /// The attributes of the Mach port.
    public var attributes: Attributes {
        get {
            Attributes(port: self)
        }
        set {
            // This is a no-op, as the subscript setter is used to set the attributes. This is just here to tell the compiler that the attributes are settable.
        }
    }

    /// A null Mach port.
    public class var null: Self {
        Self(rawValue: mach_port_t(MACH_PORT_NULL))
    }
    /// The raw Mach port.
    public var rawValue: mach_port_t
    /// Initialize a new Mach port with the given raw port.
    public required init(rawValue: mach_port_t) {
        self.rawValue = rawValue
        self.task = .current
    }
    /// Initialize a new Mach port with the given raw port in the given task.
    public required init(rawValue: mach_port_t, in task: MachTask) {
        self.rawValue = rawValue
        self.task = task
    }
    /// Allocate a new Mach port with the given right (and optionally a name).
    /// - Parameters:
    ///   - right: The right to allocate the port with.
    ///   - name: The name to allocate the port with.
    /// - Returns: The allocated port.
    public class func allocate(
        right: Right, name: mach_port_name_t? = nil, in task: MachTask = .current
    ) -> Self {
        guard [.receive, .portSet, .deadName].contains(right) else { return Self.null }
        var generatedPortName = mach_port_name_t()
        let ret =
            name != nil
            ? mach_port_allocate_name(task.rawValue, right.rawValue, name!)
            : mach_port_allocate(task.rawValue, MACH_PORT_RIGHT_RECEIVE, &generatedPortName)
        guard ret == KERN_SUCCESS else { return Self.null }
        return Self(rawValue: generatedPortName)
    }

    /// A flag for constructing a Mach port.
    public enum ConstructFlag: UInt32, COptionMacroEnum {
        case contextAsGuard = 0x01
        case queueLimit = 0x02
        case tempowner = 0x04
        case importanceReceiver = 0x08
        case insertSendRight = 0x10
        case strict = 0x20
        case denapReceiver = 0x40
        case immovableReceive = 0x80
        case filterMsg = 0x100
        case tgBlockTracking = 0x200
        case servicePort = 0x400
        case connectionPort = 0x800
        case replyPort = 0x1000
        case replyPortSemantics = 0x2000
        case provisionalReplyPort = 0x4000
        case provisionalIdProtOutput = 0x8000
        public var cMacroName: String {
            "MPO_"
                + "\(self)".replacingOccurrences(
                    of: "([a-z])([A-Z])", with: "$1_$2", options: .regularExpression
                ).uppercased()
        }
    }

    /// Construct a new Mach port.
    /// - Parameters:
    ///   - queueLimit: The queue limit of the port.
    ///   - flags: The flags to construct the port with.
    ///   - context: The context to construct the port with.
    ///   - name: The name to construct the port with.
    ///   - in: The task to construct the port in.
    /// - Returns: The constructed port, or a null port if the construction failed.
    public class func construct(
        queueLimit: mach_port_msgcount_t, flags: COptionMacroSet<ConstructFlag>,
        context: mach_port_context_t = 0,
        name: mach_port_name_t? = nil,
        in task: MachTask = .current
    ) -> Self {
        var options = mach_port_options_t()
        options.mpl.mpl_qlimit = queueLimit
        options.flags = flags.rawValue
        var portName = name ?? mach_port_name_t(MACH_PORT_NULL)
        let ret = mach_port_construct(task.rawValue, &options, context, &portName)
        guard ret == KERN_SUCCESS else { return Self.null }
        return Self(rawValue: portName)
    }
}
