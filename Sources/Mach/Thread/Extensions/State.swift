import Darwin.Mach

extension Mach.Thread {
    /// The thread's state.
    public var state: State { State(about: self) }
    /// A thread's state.
    public class State: Mach.FlavoredDataManagerNoAdditionalArgs<
        State.Flavor, thread_state_t.Pointee
    >
    {
        /// The thread.
        // let thread: Mach.Thread
        /// Get a thread's state.
        /// - Parameter thread: The thread to get the state of.
        public convenience init(about thread: Mach.Thread) {
            self.init(
                getter: { flavor, array, count, _ in
                    return thread_get_state(thread.name, flavor.rawValue, array, &count)
                },
                setter: { flavor, array, count, _ in
                    return thread_set_state(thread.name, flavor.rawValue, array, count)
                }
            )
        }
        /// A flavor of thread state.
        /// - Warning: Some of these cases are [conditionally-compiled](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/statements/#Compiler-Control-Statements)
        /// based on the architecture being targeted. Swift documentation is specifically generated from a compiled version of the code, so any
        /// cases listed here are only those that were available on the machine that generated the documentation and may not accurately reflect
        /// those available in *your* environment. For the most accurate list of cases, see the source code for this module.
        public enum Flavor: thread_state_flavor_t {
            case list = 0
            #if arch(arm) || arch(arm64)
                case arm = 1
                case armVFP = 2
                case armException = 3
                case armDebug = 4
                case none = 5
                case arm64 = 6
                case armException64 = 7
                case arm32 = 8
                case x86None = 13
                case armDebug32 = 14
                case armDebug64 = 15
                case armNeon = 16
                case armNeon64 = 17
                case armCPMU64 = 18
                case armSavedState32 = 20
                case armSavedState64 = 21
                case armNeonSavedState32 = 22
                case armNeonSavedState64 = 23
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
            case listNew = 128
            case list10_9 = 129
            case list10_13 = 130
            case list10_15 = 131
        }

        /// Get a thread's state.
        /// - Parameters:
        ///   - flavor: The flavor of the state.
        ///   - type: The type to load the state as.
        /// - Throws: An error if the state cannot be retrieved.
        public func get<InfoType>(_ flavor: Flavor, as type: InfoType.Type) throws -> InfoType {
            try super.get(flavor, as: type)
        }

        /// Set a thread's state.
        /// - Parameters:
        ///   - flavor: The flavor of the state.
        ///   - value: The value to set the state to.
        /// - Throws: An error if the state cannot be set.
        public func set<InfoType>(_ flavor: Flavor, to value: consuming InfoType) throws {
            try super.set(flavor, to: value)
        }
    }
}
