import CCompat
import Darwin
import Foundation

/// A Mach port.
open class MachPort: RawRepresentable, Hashable {
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

    /// Get the rights of the given Mach port.
    /// - Parameter port: The Mach port.
    /// - Returns: The rights of the Mach port.
    public static func rights(of port: mach_port_t) -> Set<Right> {
        var type = mach_port_type_t()
        let ret = mach_port_type(mach_task_self_, port, &type)
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
                let insertRightRet = mach_port_insert_right(
                    mach_task_self_, self.rawValue, self.rawValue, newRight.rawValue
                )
                guard insertRightRet == KERN_SUCCESS else { continue }
            }
            for oldRight in oldRights {
                var refCount = mach_port_urefs_t()
                // First, we get the current reference count for the right.
                let getRefsRet = mach_port_get_refs(
                    mach_task_self_, self.rawValue, oldRight.rawValue, &refCount
                )
                guard getRefsRet == KERN_SUCCESS else { continue }
                // Then we decrement the reference count by the current reference count, to decrement it to zero,
                // which will deallocate the right. If the reference count somehow changes between the two calls,
                // the deallocation will fail, but there doesn't seem to be an atomic way to do this.
                let modRefsRet = mach_port_mod_refs(
                    mach_task_self_, self.rawValue, oldRight.rawValue, -mach_port_delta_t(refCount)
                )
                guard modRefsRet == KERN_SUCCESS else { continue }
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
        let guardRet = mach_port_guard(mach_task_self_, self.rawValue, testGuard, 0)
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

        let unguardRet: kern_return_t = mach_port_unguard(mach_task_self_, self.rawValue, testGuard)
        guard unguardRet == KERN_SUCCESS else {
            // This should hopefully never happen, but if it does, we need to crash the program, as the port is now in an unknown state.
            fatalError("Failed to unguard the port after testing if it was guarded.")
        }
        return false
    }
    public enum GuardFlags: UInt64, COptionMacroEnum {
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
    public func `guard`(context: mach_port_context_t, flags: COptionMacroSet<GuardFlags>) throws {
        let guardRet = mach_port_guard_with_flags(
            mach_task_self_, self.rawValue, context, flags.rawValue
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
            mach_task_self_, self.rawValue, old, new
        )
        guard swapRet == KERN_SUCCESS else {
            throw NSError(domain: NSMachErrorDomain, code: Int(swapRet))
        }
    }

    /// Unguard the Mach port using the given context.
    /// - Parameter context: The context to unguard the port with.
    /// - Throws: An error if the unguarding fails.
    public func unguard(context: mach_port_context_t) throws {
        let unguardRet = mach_port_unguard(mach_task_self_, self.rawValue, context)
        guard unguardRet == KERN_SUCCESS else {
            throw NSError(domain: NSMachErrorDomain, code: Int(unguardRet))
        }
    }

    /// The Mach port context.
    public var context: mach_port_context_t {
        get {
            var context = mach_port_context_t()
            let ret = mach_port_get_context(mach_task_self_, self.rawValue, &context)
            guard ret == KERN_SUCCESS else { return mach_port_context_t() }
            return context
        }
        set {
            let ret = mach_port_set_context(mach_task_self_, self.rawValue, newValue)
            guard ret == KERN_SUCCESS else { return }
        }
    }

    public var kernelObject: KernelObject? {
        KernelObject(port: self)
    }

    /// A null Mach port.
    public static var null: Self {
        Self(rawValue: mach_port_t(MACH_PORT_NULL))
    }
    /// The raw Mach port.
    public var rawValue: mach_port_t
    /// Initialize a new Mach port with the given raw port.
    public required init(rawValue: mach_port_t) {
        self.rawValue = rawValue
    }
    /// Allocate a new Mach port with the given right (and optionally a name).
    /// - Parameters:
    ///   - right: The right to allocate the port with.
    ///   - name: The name to allocate the port with.
    /// - Returns: The allocated port.
    public static func allocate(right: Right, name: mach_port_name_t? = nil) -> Self {
        guard [.receive, .portSet, .deadName].contains(right) else { return Self.null }
        var generatedPortName = mach_port_name_t()
        let ret =
            name != nil
            ? mach_port_allocate_name(mach_task_self_, right.rawValue, name!)
            : mach_port_allocate(mach_task_self_, MACH_PORT_RIGHT_RECEIVE, &generatedPortName)
        guard ret == KERN_SUCCESS else { return Self.null }
        return Self(rawValue: generatedPortName)
    }

    /// All Mach ports in the current task.
    public static var all: [MachPort] {
        var namesCount = mach_msg_type_number_t.max
        var names: mach_port_name_array_t? = mach_port_name_array_t.allocate(
            capacity: Int(namesCount)
        )
        // the types array is not used, but it is required by `mach_port_names`
        var typesCount = mach_msg_type_number_t.max
        var types: mach_port_type_array_t? = mach_port_type_array_t.allocate(
            capacity: Int(typesCount)
        )
        let ret = mach_port_names(mach_task_self_, &names, &namesCount, &types, &typesCount)
        guard ret == KERN_SUCCESS else { return [] }
        return (0..<Int(namesCount)).map { MachPort(rawValue: names![$0]) }
    }
}
