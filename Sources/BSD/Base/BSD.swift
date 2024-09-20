import Darwin.POSIX

@_documentation(visibility: private)
/// A non-instantiable struct acting as a namespace.
public protocol Namespace {}

extension Namespace {
    @available(*, unavailable, message: "This is a namespace and cannot be instantiated.")
    public init() { fatalError() }
}

/// The BSD kernel.
/// - Important: There is also a constant named `BSD` which may interfere with autocompletion in
/// your editor. This is unfortunately unavoidable, but only affects autocompletion on the `BSD`
/// namespace itself. Any nested functionality should be unaffected. Alternatively, you can use
/// `BSDBase.BSD` to access this namespace.
public struct BSD: Namespace {}
