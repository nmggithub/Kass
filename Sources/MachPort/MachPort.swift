import CCompat
@preconcurrency import Darwin.Mach
import Foundation

/// A Mach port.
open class MachPort: RawRepresentable, Hashable, ExpressibleByNilLiteral {
    public typealias Right = MachPortRight
    public typealias GuardFlag = MachPortGuardFlag
    public typealias ConstructFlag = MachPortConstructFlag
    public typealias Attributes = MachPortAttributes
    public typealias Attribute = MachPortAttribute
    public typealias KernelObject = MachKernelObject
    /// Whether or the port was allocated by the user.
    private let userAllocated: Bool
    /// A special initializer for a null port.
    /// - Parameter nilLiteral: The nil literal.
    /// - Warning: Do not use this initializer directly. Instead, initialize this class with `nil`.
    public required init(nilLiteral: ()) {
        self.rawValue = mach_port_t(MACH_PORT_NULL)
        self.userAllocated = false
    }

    /// The raw task which the port is in.
    internal var rawTask: task_t = task_t(mach_task_self_)

    /// The task which the port is in.
    /// - Warning: This is the task that will be used for all operations on the port, so be careful when changing it.
    public var task: MachTask {
        get {
            MachTask(rawValue: self.rawTask)
        }
        set {
            self.rawTask = newValue.rawValue
        }
    }

    /// Get the rights of a raw port in a task.
    /// - Parameters:
    ///   - port: The raw port.
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

    /// The rights of the port.
    /// - Note: Both inserting and removing rights are not guaranteed to succeed. Any errors from the kernel when doing so are ignored.
    /// - Warning: Attempting to remove the `.receive` right from a guarded port may crash the program.
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

    /// Whether the port is guarded or not.
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
        // If the return code is not one of the expected ones, we need to crash the program, as the port is now in an unknown state.
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

    /// Guard the port using the given context and flags.
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

    /// Swap the guard of the port from the old context to the new context.
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

    /// Unguard the port using the given context.
    /// - Parameter context: The context to unguard the port with.
    public func unguard(context: mach_port_context_t) throws {
        let unguardRet = mach_port_unguard(self.task.rawValue, self.rawValue, context)
        guard unguardRet == KERN_SUCCESS else {
            throw NSError(domain: NSMachErrorDomain, code: Int(unguardRet))
        }
    }

    /// The port context.
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

    /// The kernel object underlying the port.
    public var kernelObject: KernelObject? {
        KernelObject(port: self)
    }

    /// The attributes of the port.
    public var attributes: Attributes {
        get { Attributes(port: self) }
        // This is a no-op, as the subscript setter is used to set the attributes. This is just here to tell the compiler that the attributes are settable.
        set {}
    }

    /// The raw port.
    public var rawValue: mach_port_t

    /// Represent an existing raw port.
    /// - Parameter rawValue: The raw port.
    public required init(rawValue: mach_port_t) {
        self.rawValue = rawValue
        self.userAllocated = false
    }

    /// Represent the raw port as another port type.
    /// - Parameter type: The type to represent the raw port as.
    /// - Returns: The raw port, represented as the given type.
    public func `as`<T: MachPort>(_ type: T.Type) -> T {
        type.init(rawValue: self.rawValue)
    }

    /// Allocate a new port with the given right (and optionally a name).
    /// - Parameters:
    ///   - right: The right to allocate the port with.
    ///   - name: The name to allocate the port with.
    ///   - task: The task to allocate the port in.
    /// - Returns: The allocated port, or `nil` if the allocation failed.
    public init?(
        right: Right, name: mach_port_name_t? = nil, in task: MachTask = .current
    ) {
        guard [.receive, .portSet, .deadName].contains(right) else { return nil }
        var generatedPortName = mach_port_name_t()
        let ret =
            name != nil
            ? mach_port_allocate_name(task.rawValue, right.rawValue, name!)
            : mach_port_allocate(task.rawValue, MACH_PORT_RIGHT_RECEIVE, &generatedPortName)
        guard ret == KERN_SUCCESS else { return nil }
        self.rawValue = name ?? generatedPortName
        self.userAllocated = true
    }

    /// Construct a new port.
    /// - Parameters:
    ///   - queueLimit: The queue limit of the port.
    ///   - flags: The flags to construct the port with.
    ///   - context: The context to construct the port with.
    ///   - name: The name to construct the port with.
    ///   - task: The task to construct the port in.
    /// - Returns: The constructed port, or `nil` if the construction failed.
    public init?(
        queueLimit: mach_port_msgcount_t, flags: COptionMacroSet<ConstructFlag>,
        context: mach_port_context_t = 0,
        name: mach_port_name_t? = nil,
        in task: MachTask = .current
    ) {
        var options = mach_port_options_t()
        options.mpl.mpl_qlimit = queueLimit
        options.flags = flags.rawValue
        var portName = name ?? mach_port_name_t(MACH_PORT_NULL)
        let ret = mach_port_construct(task.rawValue, &options, context, &portName)
        guard ret == KERN_SUCCESS else { return nil }
        self.rawValue = portName
        self.userAllocated = true
    }

    /// Deallocate the port.
    public func deallocate() {
        mach_port_deallocate(self.task.rawValue, self.rawValue)
    }

    deinit {
        if self.userAllocated { self.deallocate() }
    }
}
