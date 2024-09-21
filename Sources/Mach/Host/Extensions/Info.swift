import Darwin.Mach

extension Mach.Host {
    /// A type of host info.
    public enum Info: host_flavor_t {
        case basic = 1
        case scheduling = 3
        case resourceSizes = 4
        case priority = 5
        case semaphoreTraps = 7
        case machMsgTraps = 8
        case vmPurgeable = 9
        case debugInfo = 10
        /// - Note: Yes, this is what it's actually called.
        case canHasDebugger = 11
        case preferredUserspaceArchitecture = 12
    }
    /// Gets the value of host info.
    /// - Parameters:
    ///   - info: The info to get.
    ///   - type: The type to load the info as.
    /// - Throws: An error if the info cannot be retrieved.
    /// - Returns: The info.
    public func getHostInfo<DataType: BitwiseCopyable>(
        _ info: Info, as type: DataType.Type
    ) throws -> DataType {
        try Mach.callWithCountInOut(type: type) {
            array, count in
            host_info(self.name, info.rawValue, array, &count)
        }
    }
}
