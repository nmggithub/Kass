import Darwin.POSIX

@_documentation(visibility:private)
/// A non-instantiable struct acting as a namespace.
public protocol Namespace {}

extension Namespace {
    @available(*, unavailable, message: "This is a namespace and cannot be instantiated.")
    public init() { fatalError() }
}

/// The BSD kernel.
public struct BSD: Namespace {}