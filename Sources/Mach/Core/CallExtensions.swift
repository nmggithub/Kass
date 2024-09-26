import Darwin.Mach

extension Mach {
    /// A function that executes a kernel call that expects an array pointer and a desired count, passing an array pointer and count.
    public typealias CountInOutCallBlock<ArrayElement: BitwiseCopyable> = (
        UnsafeMutablePointer<ArrayElement>, inout mach_msg_type_number_t
    ) -> kern_return_t

    /// Executes a kernel call that expects an array pointer and a desired count and returns the result.
    public static func callWithCountInOut<ArrayElement: BitwiseCopyable>(
        count: inout mach_msg_type_number_t, _ call: CountInOutCallBlock<ArrayElement>
    ) throws -> [ArrayElement] {
        let array = UnsafeMutablePointer<ArrayElement>.allocate(capacity: Int(count))
        defer { array.deallocate() }
        try Mach.call(call(array, &count))
        return Array(UnsafeBufferPointer(start: array, count: Int(count)))
    }

    /// Executes a kernel call that expects an array pointer and a desired count and returns the result.
    public static func callWithCountInOut<ArrayElement: BitwiseCopyable, DataType: BitwiseCopyable>(
        type: DataType.Type, _ call: CountInOutCallBlock<ArrayElement>
    ) throws -> DataType {
        var count = mach_msg_type_number_t(
            MemoryLayout<DataType>.size / MemoryLayout<ArrayElement>.size
        )
        let array = try self.callWithCountInOut(count: &count, call)
        return array.withUnsafeBytes { arrayBytes in
            arrayBytes.load(as: DataType.self)
        }
    }

    /// A function that executes a kernel call expecting an array of a specified type, passing an array pointer and count.
    public typealias CountInCallBlock<ArrayElement: BitwiseCopyable> = (
        UnsafeMutablePointer<ArrayElement>, mach_msg_type_number_t
    ) -> kern_return_t

    /// Executes a kernel call with an array of a specified type.
    public static func callWithCountIn<ArrayElement: BitwiseCopyable>(
        array: [ArrayElement], _ call: CountInCallBlock<ArrayElement>
    ) throws {
        let rawArray = UnsafeMutablePointer<ArrayElement>.allocate(capacity: Int(array.count))
        defer { rawArray.deallocate() }
        rawArray.initialize(from: array, count: array.count)
        try Mach.call(call(rawArray, mach_msg_type_number_t(array.count)))
    }

    /// Executes a kernel call with a value expressed as an array of a specified type.
    public static func callWithCountIn<ArrayElement: BitwiseCopyable, DataType: BitwiseCopyable>(
        value: DataType, _ call: CountInCallBlock<ArrayElement>
    ) throws {
        let count = mach_msg_type_number_t(
            MemoryLayout<DataType>.size / MemoryLayout<ArrayElement>.size
        )
        try withUnsafeBytes(of: value) { valueBytes in
            guard let baseAddress = valueBytes.baseAddress else {
                // We couldn't get the base address, so we can't interpret the value as an array. Send an empty array instead.
                try self.callWithCountIn(array: [], call)
                return
            }
            let arrayPointer = baseAddress.bindMemory(to: ArrayElement.self, capacity: Int(count))
            try self.callWithCountIn(
                array: Array(UnsafeBufferPointer(start: arrayPointer, count: Int(count))), call
            )
        }
    }

    /// A function that executes a kernel call that returns an array of a specified type, passing an array pointer and count.
    public typealias CountOutCallBlock<ArrayElement: BitwiseCopyable> = (
        UnsafeMutablePointer<ArrayElement>?, inout mach_msg_type_number_t
    ) -> kern_return_t

    /// Executes a kernel call that returns an array of a specified type.
    public static func callWithCountOut<ArrayElement: BitwiseCopyable>(
        element: ArrayElement.Type, _ call: CountOutCallBlock<ArrayElement>
    ) throws -> [ArrayElement] {
        var count = mach_msg_type_number_t(0)
        try Mach.call(call(nil, &count))
        let array = UnsafeMutablePointer<ArrayElement>.allocate(capacity: Int(count))
        defer { array.deallocate() }
        try Mach.call(call(array, &count))
        return Array(UnsafeBufferPointer(start: array, count: Int(count)))
    }

    /// Executes a kernel call that returns an array of a specified type.
    public static func callWithCountOut<ArrayElement: BitwiseCopyable, DataType: BitwiseCopyable>(
        type: DataType.Type, _ call: CountOutCallBlock<ArrayElement>
    ) throws -> DataType {
        let array = try Mach.callWithCountOut(element: ArrayElement.self, call)
        return array.withUnsafeBytes { arrayBytes in
            arrayBytes.load(as: DataType.self)
        }
    }
}

func test() throws {
    func mach_set_array(_ array: UnsafeMutablePointer<Int32>?, _ count: mach_msg_type_number_t)
        -> kern_return_t
    {
        return KERN_SUCCESS
    }
    func mach_set_value(_ array: UnsafeMutablePointer<Int32>?, _ count: mach_msg_type_number_t)
        -> kern_return_t
    {
        return KERN_SUCCESS
    }

    func mach_get_array(
        _ array: UnsafeMutablePointer<Int32>?, _ count: inout mach_msg_type_number_t
    ) -> kern_return_t {
        return KERN_SUCCESS
    }
    func mach_get_value(
        _ array: UnsafeMutablePointer<Int32>?, _ count: inout mach_msg_type_number_t
    ) -> kern_return_t {
        return KERN_SUCCESS
    }

    func mach_get_array_2(
        _ array: UnsafeMutablePointer<Int32>?, _ count: inout mach_msg_type_number_t
    ) -> kern_return_t {
        return KERN_SUCCESS
    }
    func mach_get_value_2(
        _ array: UnsafeMutablePointer<Int32>?, _ count: inout mach_msg_type_number_t
    ) -> kern_return_t {
        return KERN_SUCCESS
    }

    typealias SomeArrayElement = Int32

    let someArray: [Int32] = [1, 2, 3, 4, 5]

    struct Foo {}
    let someValue = Foo()

    struct Bar {}
    typealias SomeType = Bar

    var someCount = mach_msg_type_number_t(5)
    struct Baz {}
    typealias SomeOtherArrayElement = Baz

    /// Count-In Array-Based Call
    try Mach.callWithCountIn(array: someArray) {
        array, count in
        mach_set_array(array, count)
    }
    /// Count-In Data-Based Call
    try Mach.callWithCountIn(value: someValue) {
        array, count in
        mach_set_value(array, count)
    }
    /// Count-Out Array-Based Call
    let array = try Mach.callWithCountOut(element: SomeArrayElement.self) {
        array, count in
        mach_get_array(array, &count)
    }
    /// Count-Out Data-Based Call
    let data = try Mach.callWithCountOut(type: SomeType.self) {
        array, count in
        mach_get_value(array, &count)
    }
    /// Count-Out Array-Based Call
    let otherArray = try Mach.callWithCountInOut(count: &someCount) {
        array, count in
        mach_get_array_2(array, &count)
    }
    /// Count-Out Data-Based Call
    let otherData = try Mach.callWithCountInOut(type: SomeType.self) {
        array, count in
        mach_get_value_2(array, &count)
    }
}
