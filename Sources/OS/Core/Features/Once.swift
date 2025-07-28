import Darwin
import KassC.OncePrivate

extension OS {
    /// A predicate for one-time operation.
    public typealias Once = os_once_t

    /// A function to be executed.
    public typealias Function = os_function_t

    /// Executes a function once passing it an optional context.
    public static func _once(
        _ predicate: inout Once, _ context: UnsafeMutableRawPointer?,
        _ function: Function
    ) {
        _os_once(&predicate, context, function)
    }

    /// Resets the given predicate.
    /// - Warning: This function is intended for internal use only
    ///     and may not work as expected in all cases.
    public static func __onceReset(_ predicate: inout Once) {
        __os_once_reset(&predicate)
    }
}
