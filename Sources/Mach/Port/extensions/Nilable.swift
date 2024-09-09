import Darwin.Mach

extension Mach.Port {
    /// A port that can be `nil`.
    public protocol Nilable: Mach.Port, ExpressibleByNilLiteral {}
}
extension Mach.Port.Nilable {
    public init(nilLiteral: ()) {
        self.init(named: Self.Nil.name)
    }
}
