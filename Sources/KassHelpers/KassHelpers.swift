/// A structure representing an enumeration of options.
@_documentation(visibility: private)
public protocol OptionEnum: RawRepresentable, Equatable, Sendable
where RawValue: Equatable {}

/// A structure representing an enumeration of options with names.
@_documentation(visibility: private)
public protocol NamedOptionEnum: OptionEnum, CaseIterable, CustomStringConvertible {
    /// The name of the option, if it can be determined.
    var name: String? { get }

    /// All known cases of the option.
    static var allCases: [Self] { get }

    /// Represents an option with a raw value.
    init(rawValue: RawValue)

    /// Represents an option with an optional name and raw value.
    init(name: String?, rawValue: RawValue)
}

/// A non-instantiable struct acting as a namespace.
@_documentation(visibility: private)
public protocol Namespace {}

extension Namespace {
    @available(*, unavailable, message: "This is a namespace and cannot be instantiated.")
    fileprivate init() { fatalError("Namespaces cannot be instantiated!") }
}

extension NamedOptionEnum {
    /// The description of the option.
    public var description: String {
        let className = String(describing: Self.self)
        let caseName = "\(name ?? "unknown") (\(rawValue))"
        return "\(className): \(caseName)"
    }

    /// Represents an option with a raw value, taking one of the known cases if the raw value matches one.
    public init(rawValue: RawValue) {
        guard let value = Self.allCases.first(where: { $0.rawValue == rawValue }) else {
            self.init(name: nil, rawValue: rawValue)
            return
        }
        self = value
    }
}
