import Darwin.Mach
import Foundation

extension Mach.Port {
    /// A flag to guard a port with.
    public enum GuardFlag: UInt64 {
        case strict = 1
        case immovableReceive = 2
    }
    /// A port that can be guarded.
    public protocol Guardable: Mach.Port {
        /// Guard the port with the specified context and flags.
        /// - Parameters:
        ///   - context: The context to guard the port with.
        ///   - flags: The flags to guard the port with.
        /// - Throws: An error if the operation fails.
        func `guard`(_ context: mach_port_context_t, flags: Set<GuardFlag>) throws
        /// Unguard the port with the specified context.
        /// - Parameter context: The context to unguard the port with.
        /// - Throws: An error if the operation fails.
        func unguard(_ context: mach_port_context_t) throws
    }
    /// A port that can be guarded and checked if it is guarded.
    public protocol GuardableExperimental: Mach.Port, Mach.Port.Guardable, Mach.Port.Loggable {
        /// Whether the port is guarded.
        var guarded: Bool { get }
    }
}

extension Mach.Port.Guardable {
    public func `guard`(_ context: mach_port_context_t, flags: Set<Mach.Port.GuardFlag> = [])
        throws
    {
        let ret = mach_port_guard_with_flags(
            self.owningTask.name, self.name, context, flags.reduce(0) { $0 | $1.rawValue }
        )
        guard ret == KERN_SUCCESS else {
            throw NSError(domain: NSMachErrorDomain, code: Int(ret))
        }
    }
    public func unguard(_ context: mach_port_context_t) throws {
        let ret = mach_port_unguard(self.owningTask.name, self.name, context)
        guard ret == KERN_SUCCESS else {
            throw NSError(domain: NSMachErrorDomain, code: Int(ret))
        }
    }
}

extension Mach.Port.GuardableExperimental {
    /// - Warning: This property being `false` doesn't mean that the port was determined *to not
    /// be guarded*. Instead, it means that it was *not* determined *to be guarded*. However, it
    /// being `true` means that the port was determined *to be guarded*.
    /// - Warning: There is no atomic way to check if a port is guarded. This property relies on
    /// a multi-step process to determine if the port is guarded. If a step fails and leaves the
    /// port in an indeterminate state, this property will crash the program.
    public var guarded: Bool {
        // There is no way to check if a port is guarded without attempting to guard it.
        self.log("Attempting to guard to test if the port is already guarded. Will unguard after.")
        let testGuard = mach_port_context_t(arc4random())
        do { try self.guard(testGuard, flags: []) } catch {
            switch (error as NSError).code {
            case Int(KERN_INVALID_ARGUMENT): return true  // The port is already guarded.
            case Int(KERN_INVALID_NAME): return false  // The port doesn't exist.
            case Int(KERN_INVALID_TASK): return false  // The port's task doesn't exist.
            case Int(KERN_INVALID_RIGHT): return false  // The port doesn't have the correct rights.
            case Int(KERN_SUCCESS): break  // The guarding worked, so we need to unguard it.
            default: fatalError(self.loggable("Unexpected error when guarding: \(error)"))
            }
        }
        do { try self.unguard(testGuard) } catch {
            fatalError(self.loggable("Failed to unguard the port: \(error)"))
        }
        return false
    }
}
