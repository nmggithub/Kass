import CCompat
import Darwin

/// A Mach port.
open class MachPort: RawRepresentable {
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
    /// The rights of the Mach port.
    /// - Note: Both inserting and removing rights are not guaranteed to succeed. Any errors from the Mach kernel when doing so are ignored.
    public var rights: Set<Right> {
        get {
            var type = mach_port_type_t()
            let ret = mach_port_type(mach_task_self_, self.rawValue, &type)
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
    func allocate(right: Right, name: mach_port_name_t? = nil) -> Self {
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
