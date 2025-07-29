import Darwin
@preconcurrency import KassC.AllocOnceImpl

extension OS {
    public typealias AllocToken = os_alloc_token_t
    public typealias _AllocOnceSlot = _os_alloc_once_s

    @MainActor
    public static var _allocOnceTable = _os_alloc_once_table

    /// Allocates memory once, optionally initializing it with a function.
    public static func _allocOnce(
        _ slot: inout _AllocOnceSlot,
        size: size_t,
        initFunction: Function? = nil
    )
        -> UnsafeMutableRawPointer?
    {
        return _os_alloc_once(&slot, size, initFunction)
    }
}
