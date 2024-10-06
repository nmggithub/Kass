import Darwin.POSIX
import Foundation

extension BSD {
    /// Gets kernel state.
    public static func sysctl<DataType>(
        _ mibNameArray: consuming [Int32],
        asArrayOf type: DataType.Type = UInt8.self
    ) throws -> [DataType] {
        // We make an initial call to get the expected size of the buffer.
        var length = size_t()
        try BSD.syscall(
            Darwin.sysctl(&mibNameArray, UInt32(mibNameArray.count), nil, &length, nil, 0)
        )
        let rawPointer = UnsafeMutableRawPointer.allocate(
            byteCount: Int(length),
            alignment: MemoryLayout<DataType>.alignment
        )
        defer { rawPointer.deallocate() }

        // Now we get the actual data, hoping that the length hasn't changed to be larger.
        let oldLength = length
        try BSD.syscall(
            Darwin.sysctl(&mibNameArray, UInt32(mibNameArray.count), rawPointer, &length, nil, 0)
        )
        // We simulate a kernel error instead of using `fatalError`, so that this failure state is recoverable.
        guard length <= oldLength else { throw POSIXError(.ERANGE) }
        let count = length / MemoryLayout<DataType>.stride
        let bufferPointer = UnsafeBufferPointer<DataType>(
            start: rawPointer.bindMemory(to: DataType.self, capacity: count), count: count
        )
        return Array(bufferPointer)
    }

    /// Gets kernel state.
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
