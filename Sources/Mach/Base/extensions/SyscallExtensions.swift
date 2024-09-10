import Darwin.Mach

extension Mach {
    public static func SyscallWithCountInOut<ArrayPointee, DataType>(
        arrayType: UnsafeMutablePointer<ArrayPointee>.Type,
        dataType: DataType.Type,
        syscall: (UnsafeMutablePointer<ArrayPointee>, inout mach_msg_type_number_t)
            -> kern_return_t
    ) throws -> DataType {
        var count = mach_msg_type_number_t(
            MemoryLayout<DataType>.size / MemoryLayout<ArrayPointee>.size
        )
        let array = arrayType.allocate(capacity: Int(count))
        defer { array.deallocate() }
        try Mach.Syscall(syscall(array, &count))
        return UnsafeMutableRawPointer(array).load(as: DataType.self)
    }
    public static func SyscallWithCountIn<ArrayPointee, DataType>(
        arrayType: UnsafeMutablePointer<ArrayPointee>.Type,
        data: DataType,
        syscall: (UnsafeMutablePointer<ArrayPointee>, mach_msg_type_number_t)
            -> kern_return_t
    ) throws {
        let count = mach_msg_type_number_t(
            MemoryLayout<DataType>.size / MemoryLayout<ArrayPointee>.size
        )
        let array = arrayType.allocate(capacity: Int(count))
        defer { array.deallocate() }
        withUnsafeBytes(of: data) { dataBytes in
            UnsafeMutableRawPointer(array).copyMemory(
                from: dataBytes.baseAddress!, byteCount: dataBytes.count
            )
        }
        try Mach.Syscall(syscall(array, count))
    }

}
