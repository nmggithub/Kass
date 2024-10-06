import Darwin.Mach
import Foundation
import KassHelpers

extension Mach {
    /// A direction for converting thread states.
    public struct ThreadStateConvertDirection: KassHelpers.OptionEnum {
        /// The raw value of the direction.
        public let rawValue: Int32

        /// Represents a raw direction value.
        public init(rawValue: Int32) { self.rawValue = rawValue }

        /// Converts the state to the current thread.
        public static let toSelf = Self(rawValue: THREAD_CONVERT_THREAD_STATE_TO_SELF)

        /// Converts the state from the current thread.
        public static let fromSelf = Self(rawValue: THREAD_CONVERT_THREAD_STATE_FROM_SELF)
    }
}

extension Mach.ThreadStateManager {
    /// Converts a thread state either to or from the current thread.
    /// - Note: When getting state from ARM threads, what is often returned by the kernel is a
    /// thread-specific **user space form** of the state. This function can be used to convert
    /// state from the current thread to work with another, or vice versa.
    /// - Note: On x86 threads, this function does nothing but return the same state that was passed in.
    public static func convert<DataType: BitwiseCopyable>(
        _ state: DataType, withFlavor flavor: Mach.ThreadStateFlavor,
        thread: Mach.Thread, direction: Mach.ThreadStateConvertDirection
    ) throws -> DataType {
        try Mach.callWithCountInOut(type: DataType.self) {
            (array: thread_state_t, count) in
            do {
                // Nesting "calls" like this isn't pretty, but this **one** kernel call uses both the count-in and
                // count-in-out patterns. That's not enough to justify a new function, so we'll just do this.
                try Mach.callWithCountIn(value: state) {
                    arrayInner, countInner in
                    thread_convert_thread_state(
                        thread.name,
                        direction.rawValue,
                        flavor.rawValue,
                        arrayInner,
                        countInner,
                        array,
                        &count
                    )
                }
            } catch {  // Catch and return the codes from the actual kernel call.
                return switch error {
                case is MachError: (error as! MachError).code.rawValue
                default: kern_return_t((error as NSError).code)
                }
            }
            // We didn't catch anything, so we assume success and return the success code.
            return MachErrorCode.success.rawValue
        }
    }

    /// Converts a thread state from the current thread to another thread.
    /// - Note: See ``convert(_:withFlavor:thread:direction:)`` for more information.
    public static func convert<DataType: BitwiseCopyable>(
        _ state: DataType, withFlavor flavor: Mach.ThreadStateFlavor,
        toThread: Mach.Thread
    ) throws -> DataType {
        try self.convert(state, withFlavor: flavor, thread: toThread, direction: .fromSelf)
    }

    /// Converts a thread state from another thread to the current thread.
    /// - Note: See ``convert(_:withFlavor:thread:direction:)`` for more information.
    public static func convert<DataType: BitwiseCopyable>(
        _ state: DataType, withFlavor flavor: Mach.ThreadStateFlavor,
        fromThread: Mach.Thread
    ) throws -> DataType {
        try self.convert(state, withFlavor: flavor, thread: fromThread, direction: .toSelf)
    }
}
