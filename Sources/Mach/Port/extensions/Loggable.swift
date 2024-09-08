import Darwin.Mach
import Foundation
import MachBase

extension Mach.Port {
    /// A port with a loggable name.
    public protocol Loggable: Mach.Port {
        /// The name of the port formatted for logging.
        var loggableName: String { get }
        /// Format a message about the port for logging.
        /// - Parameter message: The message to format.
        /// - Returns: The formatted message.
        func loggable(_ message: String) -> String
        /// Log a message about the port.
        /// - Parameter message: The message to log.
        func log(_ message: String)
    }
}

extension Mach.Port.Loggable {
    public var loggableName: String {
        return String(format: "0x%08x", self.name)
    }
    public func loggable(_ message: String) -> String {
        return "[port: \(self.loggableName)] \(message)"
    }
    public func log(_ message: String) {
        print(self.loggable(message))
    }
}
