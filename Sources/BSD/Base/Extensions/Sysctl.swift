import Darwin.POSIX

extension BSD {
    /// Gets system information.
    /// - Parameters:
    ///   - mibNameArray: The MiB name, expressed as an array of integers.
    ///   - type: The data type of the system information.
    /// - Throws: If the system information cannot be retrieved.
    /// - Returns: The system information.
    public static func sysctl<DataType>(
        _ mibNameArray: consuming [Int32],
        asArrayOf type: DataType.Type = UInt8.self
    ) throws -> [DataType] {
        var length = size_t()
        try BSD.syscall(
            Darwin.sysctl(&mibNameArray, UInt32(mibNameArray.count), nil, &length, nil, 0))
        let rawPointer = UnsafeMutableRawPointer.allocate(
            byteCount: Int(length),
            alignment: MemoryLayout<DataType>.alignment
        )
        defer { rawPointer.deallocate() }
        // hopefully the length hasn't changed
        try BSD.syscall(
            Darwin.sysctl(&mibNameArray, UInt32(mibNameArray.count), rawPointer, &length, nil, 0))
        let count = length / MemoryLayout<DataType>.stride
        let bufferPointer = UnsafeBufferPointer<DataType>(
            start: rawPointer.bindMemory(to: DataType.self, capacity: count), count: count
        )
        return Array(bufferPointer)
    }
    /// Gets system information.
    /// - Parameters:
    ///   - mibName: The MiB name, expressed as a string.
    ///   - type: The data type of the system information.
    /// - Throws: If the system information cannot be retrieved.
    /// - Returns: The system information.
    public static func sysctl<DataType>(
        _ mibName: String,
        asArrayOf type: DataType.Type = UInt8.self
    ) throws -> [DataType] {
        var mibNameArrayLength = size_t()
        try BSD.syscall(sysctlnametomib(mibName, nil, &mibNameArrayLength))
        var mibNameArray = [Int32](repeating: 0, count: Int(mibNameArrayLength))
        try BSD.syscall(sysctlnametomib(mibName, &mibNameArray, &mibNameArrayLength))
        return try BSD.sysctl(mibNameArray, asArrayOf: type)
    }
}
