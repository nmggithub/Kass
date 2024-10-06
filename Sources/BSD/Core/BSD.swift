import Darwin.POSIX
import KassHelpers

/// The BSD kernel.
/// - Important: In some cases, such as if the `Foundation` module is imported, there will be
/// a constant named `BSD` that conflicts with this struct. In those cases, `BSDCore.BSD` may
/// be used to access this struct. This is not required, but it is recommended.
public struct BSD: KassHelpers.Namespace {}
