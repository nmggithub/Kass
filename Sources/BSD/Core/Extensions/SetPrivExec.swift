import Linking

typealias setprivexec_f = @convention(c) (Int32) -> Int32
let setprivexec: setprivexec_f = libSystem.get(symbol: "setprivexec")!.cast()

extension BSD {
    /// Allows or disallows the current process the be a debugger.
    /// - Note: The flag that this sets appears to be mostly unused in the kernel proper.
    public func setPrivExec(_ state: Bool) throws {
        try BSD.call(
            setprivexec(state ? 1 : 0)
        )
    }
}
