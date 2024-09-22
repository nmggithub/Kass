import CCompat
import Darwin.Mach
import Foundation.NSError

extension Mach.Port {
    /// A flag to guard a port with.
    public enum GuardFlag: UInt64 {
        case strict = 1
        case immovableReceive = 2
    }
    /// Guards the port with the specified context and flags.
    /// - Parameters:
    ///   - context: The context to guard the port with.
    ///   - flags: The flags to guard the port with.
    /// - Throws: An error if the operation fails.
    public func `guard`(_ context: mach_port_context_t, flags: Set<Mach.Port.GuardFlag> = [])
        throws
    {
        try Mach.call(
            mach_port_guard_with_flags(
                self.owningTask.name, self.name, context, flags.bitmap()
            )
        )
    }
    /// Unguards the port with the specified context.
    /// - Parameter context: The context to unguard the port with.
    /// - Throws: An error if the operation fails.
    public func unguard(_ context: mach_port_context_t) throws {
        try Mach.call(mach_port_unguard(self.owningTask.name, self.name, context))
    }

    /// ***Experimental.*** Whether the port is guarded.
    /// - Warning: This property being `false` doesn't mean that the port was determined *to not
    /// be guarded*. Instead, it means that it was *not* determined *to be guarded*. However, it
    /// being `true` means that the port was determined *to be guarded*.
    /// - Warning: There is no atomic way to check if a port is guarded. This property relies on
    /// a multi-step process to determine if the port is guarded. If a step fails and leaves the
    /// port in an indeterminate state, this property will crash the program.
    public var guarded: Bool {
        // There is no way to check if a port is guarded without attempting to guard it.
        let testGuard = mach_port_context_t(arc4random())
        do { try self.guard(testGuard, flags: []) } catch {
            switch (error as NSError).code {
            case Int(KERN_INVALID_ARGUMENT): return true  // The port is already guarded.
            case Int(KERN_INVALID_NAME): return false  // The port doesn't exist.
            case Int(KERN_INVALID_TASK): return false  // The port's task doesn't exist.
            case Int(KERN_INVALID_RIGHT): return false  // The port doesn't have the correct rights.
            default: fatalError("Unexpected error when guarding the port: \(error)")
            }
        }
        // The guarding worked, so we need to unguard it.
        do { try self.unguard(testGuard) } catch {
            fatalError("Failed to unguard the port: \(error)")
        }
        return false
    }
}
