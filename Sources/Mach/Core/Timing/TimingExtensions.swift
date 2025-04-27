import Foundation

@available(macOS 13.0, *)
extension Duration {
    /// The duration as a `mach_timespec_t`.
    public var machTimespec: mach_timespec_t {
        let seconds = UInt32(self / .seconds(1))
        let nanoseconds = Int32((self - .seconds(seconds)) / .nanoseconds(1))
        return mach_timespec_t(tv_sec: seconds, tv_nsec: nanoseconds)
    }
}
