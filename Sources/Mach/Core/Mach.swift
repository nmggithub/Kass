import Darwin.Mach
import Foundation

@_documentation(visibility: private)
/// A non-instantiable struct acting as a namespace.
public protocol Namespace {}

extension Namespace {
    @available(*, unavailable, message: "This is a namespace and cannot be instantiated.")
    public init() { fatalError() }
}

/// The Mach kernel.
public struct Mach: Namespace {
    /// Calls the kernel and throws an error if the call fails.
    public static func call(_ call: @autoclosure () -> kern_return_t) throws {
        let kr = call()
        guard kr == KERN_SUCCESS else {
            guard let typedCode = MachError.Code(rawValue: kr) else {
                // Let's try again with an `NSError`. We use `NSMachErrorDomain` because this is still a Mach error (we hope).
                throw NSError(domain: NSMachErrorDomain, code: Int(kr))
            }
            throw MachError(typedCode)
        }
    }
}
