import CCompat
import Foundation
import MachO

/// A Mach port.
public protocol MachPort: RawRepresentable, Hashable, ExpressibleByNilLiteral
where RawValue == mach_port_t {
    typealias Right = MachPortRight
    typealias GuardFlag = MachPortGuardFlag
    typealias ConstructFlag = MachPortConstructFlag
    typealias Attributes = MachPortAttributes
    typealias Attribute = MachPortAttribute
    typealias KernelObject = MachKernelObject
    init(rawValue: mach_port_t)
    func `as`<T: MachPort>(_ type: T.Type) -> T
    var task: MachTask { get set }
    var rights: Set<Right> { get set }
    var guarded: Bool { get }
    func `guard`(context: mach_port_context_t, flags: COptionMacroSet<GuardFlag>) throws
    func swapGuard(old: mach_port_context_t, new: mach_port_context_t) throws
    func unguard(context: mach_port_context_t) throws
    var context: mach_port_context_t { get set }
    var kernelObject: KernelObject? { get }
    var attributes: Attributes { get set }
    static func allocate(
        right: Right, name: mach_port_name_t?, in task: MachTask
    ) -> Self
    static func construct(
        queueLimit: mach_port_msgcount_t, flags: COptionMacroSet<ConstructFlag>,
        context: mach_port_context_t, name: mach_port_name_t?, in task: MachTask
    ) -> Self
}

/// A wrapper for a Mach port.
open class MachPortImpl: MachPort {
    /// A special initializer for a null port.
    /// - Parameter nilLiteral: The nil literal.
    /// - Warning: Do not use this initializer directly. Instead, initialize this class with `nil`.
    public required init(nilLiteral: ()) {
        self.rawValue = mach_port_t(MACH_PORT_NULL)
    }

    /// The raw reference to the task that the Mach port is in.
    internal var rawTask: task_t = task_t(mach_task_self_)

    /// The task which the Mach port is in.
    /// - Warning: This is the task that will be used for all operations on the port, so be careful when changing it.
    public var task: MachTask {
        get {
            MachTask(rawValue: self.rawTask)
        }
        set {
            self.rawTask = newValue.rawValue
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
    /// - Warning: This is not atomic, as it requires attempting to guard the port, and then unguarding it if needed. If an unexpected error
    ///            occurs during this process, the program will deliberately crash as the port would then be in an unknown state.
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

    /// Guard the Mach port using the given context and flags.
    /// - Parameters:
    ///   - context: The context to guard the port with.
    ///   - flags: The flags to guard the port with.
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

    /// The kernel object underlying the Mach port.
    public var kernelObject: KernelObject? {
        KernelObject(port: self)
    }

    /// The attributes of the Mach port.
    public var attributes: Attributes {
        get { Attributes(port: self) }
        // This is a no-op, as the subscript setter is used to set the attributes. This is just here to tell the compiler that the attributes are settable.
        set {}
    }

    /// The raw Mach port.
    public var rawValue: mach_port_t
    /// Wrap a given port.
    public required init(rawValue: mach_port_t) {
        self.rawValue = rawValue
    }

    public func `as`<T: MachPort>(_ type: T.Type) -> T {
        type.init(rawValue: self.rawValue)
    }

    /// Allocate a new Mach port with the given right (and optionally a name).
    /// - Parameters:
    ///   - right: The right to allocate the port with.
    ///   - name: The name to allocate the port with.
    ///   - task: The task to allocate the port in.
    /// - Returns: The allocated port.
    public class func allocate(
        right: Right, name: mach_port_name_t? = nil, in task: MachTask = .current
    ) -> Self {
        guard [.receive, .portSet, .deadName].contains(right) else { return nil }
        var generatedPortName = mach_port_name_t()
        let ret =
            name != nil
            ? mach_port_allocate_name(task.rawValue, right.rawValue, name!)
            : mach_port_allocate(task.rawValue, MACH_PORT_RIGHT_RECEIVE, &generatedPortName)
        guard ret == KERN_SUCCESS else { return nil }
        return Self(rawValue: generatedPortName)
    }

    /// Construct a new Mach port.
    /// - Parameters:
    ///   - queueLimit: The queue limit of the port.
    ///   - flags: The flags to construct the port with.
    ///   - context: The context to construct the port with.
    ///   - name: The name to construct the port with.
    ///   - task: The task to construct the port in.
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
        guard ret == KERN_SUCCESS else { return nil }
        return Self(rawValue: portName)
    }
}
