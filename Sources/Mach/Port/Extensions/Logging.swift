import Darwin.Mach

extension Mach.Port {
    public var description: String {
        return self.loggableName
    }
    /// The name of the port formatted for logging.
    public var loggableName: String {
        return String(format: "0x%08x", self.name)
    }
    /// Formats a message about the port for logging.
    /// - Parameter message: The message to format.
    /// - Returns: The formatted message.
    public func loggable(_ message: String) -> String {
        return "[port: \(self.loggableName)] \(message)"
    }
    /// Logs a message about the port.
    /// - Parameter message: The message to log.
    public func log(_ message: String) {
        print(self.loggable(message))
    }
}
