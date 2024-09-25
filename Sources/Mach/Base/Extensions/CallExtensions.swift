import Darwin.Mach

extension Mach {
    /// A function that executes a CountInOut kernel call, passing an array pointer and count.
    public typealias CountInOutCall<ArrayPointee: BitwiseCopyable> = (
        UnsafeMutablePointer<ArrayPointee>, inout mach_msg_type_number_t
    ) -> kern_return_t

    /// Executes a CountInOut kernel call and returns the result.
    /// - Parameters:
    ///   - count: The desired count of the array.
    ///   - call: A function that executes the kernel call and passes the array pointer and count.
    /// - Throws: An error if the operation fails.
    /// - Returns: The array result of the kernel call.
    public static func callWithCountInOut<ArrayPointee: BitwiseCopyable>(
        count: inout mach_msg_type_number_t, _ call: CountInOutCall<ArrayPointee>
    ) throws -> [ArrayPointee] {
        let array = UnsafeMutablePointer<ArrayPointee>.allocate(capacity: Int(count))
        defer { array.deallocate() }
        try Mach.call(call(array, &count))
        return Array(UnsafeBufferPointer(start: array, count: Int(count)))
    }

    /// Executes a CountInOut kernel call and returns the result.
    /// - Parameters:
    ///   - type: The type to load the result as.
    ///   - call: A function that executes the kernel call.
    /// - Throws: An error if the operation fails.
    /// - Returns: The result of the kernel call loaded as the specified type.
    public static func callWithCountInOut<ArrayPointee: BitwiseCopyable, DataType: BitwiseCopyable>(
        type: DataType.Type, _ call: CountInOutCall<ArrayPointee>
    ) throws -> DataType {
        var count = mach_msg_type_number_t(
            MemoryLayout<DataType>.size / MemoryLayout<ArrayPointee>.size
        )
        let array = try self.callWithCountInOut(count: &count, call)
        return array.withUnsafeBytes { arrayBytes in
            arrayBytes.load(as: DataType.self)
        }
    }

    /// A function that executes a kernel call expecting an array of a specified type, passing an array pointer and count.
    public typealias CountInCall<ArrayPointee: BitwiseCopyable> = (
        UnsafeMutablePointer<ArrayPointee>, mach_msg_type_number_t
    ) -> kern_return_t

    /// Executes a kernel call with an array of a specified type.
    /// - Parameters:
    ///   - array: The array to pass to the kernel call.
    ///   - call: A function that executes the kernel call and passes the array pointer and count.
    /// - Throws: An error if the operation fails.
    public static func callWithCountIn<ArrayPointee: BitwiseCopyable>(
        array: [ArrayPointee], _ call: CountInCall<ArrayPointee>
    ) throws {
        let rawArray = UnsafeMutablePointer<ArrayPointee>.allocate(capacity: Int(array.count))
        defer { rawArray.deallocate() }
        rawArray.initialize(from: array, count: array.count)
        try Mach.call(call(rawArray, mach_msg_type_number_t(array.count)))
    }

    /// Executes a kernel call with a value expressed as an array of a specified type.
    /// - Parameters:
    ///   - value: The value to pass to the kernel call.
    ///   - call: A function that executes the kernel call and passes the array pointer and count.
    /// - Throws: An error if the operation fails.
    /// - Note: This function will automatically convert the value to an array of the specified type.
    public static func callWithCountIn<ArrayPointee: BitwiseCopyable, DataType: BitwiseCopyable>(
        value: DataType, _ call: CountInCall<ArrayPointee>
    ) throws {
        let count = mach_msg_type_number_t(
            MemoryLayout<DataType>.size / MemoryLayout<ArrayPointee>.size
        )
        try withUnsafeBytes(of: value) { valueBytes in
            guard let baseAddress = valueBytes.baseAddress else {
                // We couldn't get the base address, so we can't interpret the value as an array. Send an empty array instead.
                try self.callWithCountIn(array: [], call)
                return
            }
            let arrayPointer = baseAddress.bindMemory(to: ArrayPointee.self, capacity: Int(count))
            try self.callWithCountIn(
                array: Array(UnsafeBufferPointer(start: arrayPointer, count: Int(count))), call
            )
        }
    }

    /// A function that executes a kernel call that returns an array of a specified type, passing an array pointer and count.
    public typealias CountOutCall<ArrayPointee: BitwiseCopyable> = (
        UnsafeMutablePointer<ArrayPointee>?, inout mach_msg_type_number_t
    ) -> kern_return_t

    /// Executes a kernel call that returns an array of a specified type.
    /// - Parameter call: A function that executes the kernel call and passes the array pointer and count.
    /// - Throws: An error if the operation fails.
    /// - Returns: The array result of the kernel call.
    public static func callWithCountOut<ArrayPointee: BitwiseCopyable>(
        _ call: CountOutCall<ArrayPointee>
    ) throws -> [ArrayPointee] {
        var count = mach_msg_type_number_t(0)
        try Mach.call(call(nil, &count))
        let array = UnsafeMutablePointer<ArrayPointee>.allocate(capacity: Int(count))
        defer { array.deallocate() }
        try Mach.call(call(array, &count))
        return Array(UnsafeBufferPointer(start: array, count: Int(count)))
    }

    /// Executes a kernel call that returns an array of a specified type.
    /// - Parameter call: A function that executes the kernel call and passes the array pointer and count.
    /// - Throws: An error if the operation fails.
    /// - Returns: The result of the kernel call loaded as the specified type.
    public static func callWithCountOut<ArrayPointee: BitwiseCopyable, DataType: BitwiseCopyable>(
        type: DataType.Type, _ call: CountOutCall<ArrayPointee>
    ) throws -> DataType {
        let array = try Mach.callWithCountOut(call)
        return array.withUnsafeBytes { arrayBytes in
            arrayBytes.load(as: DataType.self)
        }
    }
}
