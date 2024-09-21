import Darwin.Mach

extension Mach.Host {
    /// A collection of host statistics.
    public enum HostStatistics: host_flavor_t {
        case load = 1
        case vm = 2
        case cpuLoad = 3
        case vm64 = 4
        case extMod = 5
        case expiredTasks = 6
    }

    /// Gets the host's statistics.
    /// - Parameters:
    ///   - collection: The collection of statistics to get.
    ///   - type: The type to load the statistics as.
    /// - Throws: An error if the statistics cannot be retrieved.
    public func getStatistics<DataType: BitwiseCopyable>(
        _ collection: HostStatistics, as type: DataType.Type
    ) throws -> DataType {
        try Mach.callWithCountInOut(type: type) {
            array, count in
            switch collection {
            case .load, .vm, .cpuLoad, .expiredTasks:
                host_statistics(self.name, collection.rawValue, array, &count)
            case .vm64, .extMod:
                host_statistics64(self.name, collection.rawValue, array, &count)
            }
        }
    }
}
