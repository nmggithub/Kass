import Darwin
import KassC.AllocOnceImpl

extension OS {
    public typealias AllocToken = os_alloc_token_t
    public typealias _AllocOnceSlot = _os_alloc_once_s

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
