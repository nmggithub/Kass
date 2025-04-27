/// An object that can be represented as shellcode.
public protocol ShellcodeRepresentable {
    /// The raw shellcode.
    var shellcode: [UInt8] { get }
}
