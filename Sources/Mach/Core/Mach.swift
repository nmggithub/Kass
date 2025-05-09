import Darwin.Mach
import Foundation
import KassHelpers

/// The Mach kernel.
public struct Mach: KassHelpers.Namespace {
    /// Executes a function that returns a Mach error code and throw an error if it fails.
    // This honestly may not need to be `@autoclosure`, as it immediately evaluates the call, but it's been
    //  this way since the beginning, so let's keep it that way for now. Additionally, if we were to remove
    //  the `@autoclosure`, the semantics would change and make "call" not really make sense as a name, and
    //  we don't really want to have to change the name of this function. It is succinct and it matches the
    //  the name of the similar kernel-calling function in BSDCore.
    public static func call(_ call: @autoclosure () -> kern_return_t) throws {
        let kr = call()
        guard kr == KERN_SUCCESS else {
            guard let typedCode = MachError.Code(rawValue: kr) else {
                // Let's try again with an `NSError`. We use `NSMachErrorDomain` because this is still a Mach error (we hope).
                throw NSError(domain: NSMachErrorDomain, code: Int(kr))
            }
            throw MachError(typedCode)
        }
    }
}

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
