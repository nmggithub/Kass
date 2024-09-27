import Darwin.Mach

extension Mach {
    /// A type of thread state.
    /// - Warning: Some of these cases are [conditionally-compiled](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/statements/#Compiler-Control-Statements)
    /// based on the architecture being targeted. Swift documentation is necessarily generated from a compiled version of the code, so any
    /// cases listed here are only those that were available on the machine that generated the documentation and may not accurately reflect
    /// those available in *your* environment. For the most accurate list of cases, see the source code for this module.
    public enum ThreadState: thread_state_flavor_t {
        #if arch(arm) || arch(arm64)
            case arm = 1
            case vfp = 2
            case exception = 3
            case debug = 4
            case none = 5
            case arm64 = 6
            case armException64 = 7
            case arm32 = 8
            case x86None = 13
            case debug32 = 14
            case debug64 = 15
            case armNeon = 16
            case armNeon64 = 17
            case armCPMU64 = 18
            case armPageIn = 27
        #elseif arch(i386) || arch(x86_64)
            case x86_32 = 1
            case x86Float32 = 2
            case x86Exception32 = 3
            case x86_64 = 4
            case x86Float64 = 5
            case x86Exception64 = 6
            case x86 = 7
            case x86Float = 8
            case x86Exception = 9
            case x86Debug32 = 10
            case x86Debug64 = 11
            case x86Debug = 12
            case none = 13

            // these both are an educated guess based on comments in the kernel
            case x86SavedState32 = 14
            case x86SavedState64 = 15

            case x86AVX32 = 16
            case x86AVX64  // +1
            case x86AVX  // +2
            case x86AVX512_32 = 19
            case x86AVX512_64  // +1
            case x86AVX512  // +2
            case x86PageIn = 22
            case x86Full = 23
            case x86Instruction = 24
            case x86LastBranch = 25
        #endif
    }
}

extension Mach.Thread {
    /// Gets the thread's state.
    public func getState<StateDataType: BitwiseCopyable>(
        _ state: Mach.ThreadState, as type: StateDataType.Type
    ) throws -> StateDataType {
        try Mach.callWithCountInOut(type: type) {
            (array: thread_state_t, count) in
            thread_get_state(self.name, state.rawValue, array, &count)
        }
    }

    /// Sets the thread's state.
    public func setState(
        _ state: Mach.ThreadState, to value: BitwiseCopyable
    ) throws {
        try Mach.callWithCountIn(value: value) {
            (array: thread_state_t, count) in
            thread_set_state(self.name, state.rawValue, array, count)
        }
    }
}

extension Mach.ThreadState {
    /// Gets the state for a thread.
    public func get<StateDataType: BitwiseCopyable>(
        as type: StateDataType.Type, for thread: Mach.Thread = .current
    ) throws -> StateDataType { try thread.getState(self, as: type) }

    /// Sets the state for a thread.
    public func set(
        to value: BitwiseCopyable, for thread: Mach.Thread = .current
    ) throws { try thread.setState(self, to: value) }
}
