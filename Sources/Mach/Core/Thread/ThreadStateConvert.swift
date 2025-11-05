import Darwin.Mach
import Foundation
import KassHelpers

extension Mach {
    /// A direction for converting thread states.
    public struct ThreadStateConversionDirection: KassHelpers.OptionEnum {
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

extension Mach.ThreadState {
    /// Converts a thread state either to or from the current thread.
    public func convert(thread: Mach.Thread, direction: Mach.ThreadStateConversionDirection) throws
        -> DataType
    {
        try Mach.callWithCountInOut(type: DataType.self) {
            (array: thread_state_t, count) in
            do {
                // Nesting "calls" like this isn't pretty, but this is one of the only kernel call that uses both the count-in
                // and count-in-out patterns. That's not enough to justify a new function, so we'll just do this.
                try Mach.callWithCountIn(value: self.data) {
                    arrayInner, countInner in
                    thread_convert_thread_state(
                        thread.name,
                        direction.rawValue,
                        self.flavorKey,
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
    public func convert(toThread thread: Mach.Thread) throws
        -> DataType
    { try self.convert(thread: thread, direction: .fromSelf) }

    /// Converts a thread state from another thread to the current thread.
    public func convert(fromThread thread: Mach.Thread) throws
        -> DataType
    { try self.convert(thread: thread, direction: .toSelf) }
}
