import Darwin.Mach
import Foundation

extension MachError {
    /// Initializes a new Mach error with a given code.
    /// - Parameter code: The error code.
    public init(_ code: kern_return_t) {
        guard let typedCode = MachError.Code(rawValue: code) else {
            fatalError("Invalid Mach error code: \(code)")
        }
        self.init(typedCode)
    }
}

extension Mach {
    /// Executes a call and throw an error if it fails.
    /// - Parameter call: A statement that executes a call and returns a kernel return code.
    /// - Throws: An error if the call fails.
    public static func call(_ call: @autoclosure () -> kern_return_t) throws {
        let kr = call()
        guard kr == KERN_SUCCESS else { throw MachError(kr) }
    }
}
