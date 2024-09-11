import Darwin.POSIX

extension BSD {
    /// Get system information.
    /// - Parameters:
    ///   - mibNameArray: The MiB name, expressed as an array of integers.
    ///   - type: The data type of the system information.
    /// - Throws: If the system information cannot be retrieved.
    /// - Returns: The system information.
    public static func Sysctl<DataType>(
        _ mibNameArray: consuming [Int32],
        as type: DataType.Type = UInt8.self
    ) throws -> UnsafeBufferPointer<DataType> {
        var length = size_t()
        try BSD.Syscall(sysctl(&mibNameArray, UInt32(mibNameArray.count), nil, &length, nil, 0))
        let buffer = UnsafeMutableRawPointer.allocate(
            byteCount: Int(length),
            alignment: MemoryLayout<DataType>.alignment
        )
        // hopefully the length hasn't changed
        try BSD.Syscall(sysctl(&mibNameArray, UInt32(mibNameArray.count), buffer, &length, nil, 0))
        let count = length / MemoryLayout<DataType>.stride
        return UnsafeBufferPointer<DataType>(
            start: buffer.bindMemory(to: DataType.self, capacity: count), count: count
        )
    }
    /// Get system information.
    /// - Parameters:
    ///   - mibName: The MiB name, expressed as a string.
    ///   - type: The data type of the system information.
    /// - Throws: If the system information cannot be retrieved.
    /// - Returns: The system information.
    public static func Sysctl<DataType>(
        _ mibName: String,
        as type: DataType.Type = UInt8.self
    ) throws -> UnsafeBufferPointer<DataType> {
        var mibNameArrayLength = size_t()
        try BSD.Syscall(sysctlnametomib(mibName, nil, &mibNameArrayLength))
        var mibNameArray = [Int32](repeating: 0, count: Int(mibNameArrayLength))
        try BSD.Syscall(sysctlnametomib(mibName, &mibNameArray, &mibNameArrayLength))
        return try BSD.Sysctl(mibNameArray, as: type)
    }
}
