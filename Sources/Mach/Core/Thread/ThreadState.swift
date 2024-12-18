import Darwin.Mach
import KassHelpers

// Technically, there's nothing stopping an ARM thread from getting and setting state on an x86 thread (and visa versa), but the
// headers containing the state structs are only available on the correct architecture, so we can't provide a cross-architecture
// API without duplicating the structs (which we won't do). Maybe later, but no promises.

extension Mach {
    // MARK: - Thread State Flavors

    /// A flavor of thread state.
    public struct ThreadStateFlavor: KassHelpers.OptionEnum {
        public let rawValue: thread_state_flavor_t
        public init(rawValue: thread_state_flavor_t) { self.rawValue = rawValue }

        /// Clears the default state when used with ``Mach/Task/setDefaultThreadState(_:to:)``.
        public static let none = Self(rawValue: THREAD_STATE_NONE)

        #if arch(arm) || arch(arm64)
            /// ARM state (32-bit).
            public static let arm32 = Self(rawValue: ARM_THREAD_STATE)

            /// ARM state (64-bit).
            public static let arm64 = Self(rawValue: ARM_THREAD_STATE64)

            /// ARM exception state (32-bit).
            public static let armException32 = Self(rawValue: ARM_EXCEPTION_STATE)

            /// ARM exception state (64-bit).
            public static let armException64 = Self(rawValue: ARM_EXCEPTION_STATE64)

            /// ARM debug state (32-bit, pre-Armv8).
            public static let armDebugLegacy = Self(rawValue: ARM_DEBUG_STATE)

            /// ARM debug state (32-bit).
            public static let armDebug32 = Self(rawValue: ARM_DEBUG_STATE32)

            /// ARM debug state (64-bit).
            public static let armDebug64 = Self(rawValue: ARM_DEBUG_STATE64)

            /// ARM page-in state.
            public static let armPageIn = Self(rawValue: ARM_PAGEIN_STATE)

            /// ARM VFP state.
            public static let armVFP = Self(rawValue: ARM_VFP_STATE)

        #elseif arch(i386) || arch(x86_64)
            /// x86 state (32-bit).
            public static let x86_32 = Self(rawValue: x86_THREAD_STATE32)

            /// x86 state (64-bit).
            public static let x86_64 = Self(rawValue: x86_THREAD_STATE64)

            /// x86 state (64-bit, full).
            public static let x86Full64 = Self(rawValue: x86_THREAD_FULL_STATE64)

            /// x86 exception state (32-bit).
            public static let x86Exception32 = Self(rawValue: x86_EXCEPTION_STATE32)

            /// x86 exception state (64-bit).
            public static let x86Exception64 = Self(rawValue: x86_EXCEPTION_STATE64)

            /// x86 floating-point state (32-bit).
            public static let x86Float32 = Self(rawValue: x86_FLOAT_STATE32)

            /// x86 floating-point state (64-bit).
            public static let x86Float64 = Self(rawValue: x86_FLOAT_STATE64)

            /// x86 debug state (32-bit).
            public static let x86Debug32 = Self(rawValue: x86_DEBUG_STATE32)

            /// x86 debug state (64-bit).
            public static let x86Debug64 = Self(rawValue: x86_DEBUG_STATE64)

            /// x86 AVX state (32-bit).
            public static let x86AVX32 = Self(rawValue: x86_AVX_STATE32)

            /// x86 AVX state (64-bit).
            public static let x86AVX64 = Self(rawValue: x86_AVX_STATE64)

            /// x86 page-in state.
            public static let x86PageIn = Self(rawValue: x86_PAGEIN_STATE)

            /// x86 instruction state.
            public static let x86Instruction = Self(rawValue: x86_INSTRUCTION_STATE)

            /// x86 last branch record state.
            public static let x86LastBranch = Self(rawValue: x86_LAST_BRANCH_STATE)
        #endif
    }

    // MARK: - Thread State Manager

    /// A thread state manager.
    public struct ThreadStateManager: FlavoredDataManager {
        /// The thread.
        public let thread: Mach.Thread

        /// Creates a thread state manager.
        public init(thread: Mach.Thread) { self.thread = thread }

        /// Gets the state of the thread.
        public func get<DataType>(
            _ flavor: Mach.ThreadStateFlavor, as type: DataType.Type = DataType.self
        ) throws -> DataType where DataType: BitwiseCopyable {
            try Mach.callWithCountInOut(type: type) {
                (array: thread_state_t, count) in
                thread_get_state(self.thread.name, flavor.rawValue, array, &count)
            }
        }

        /// Sets the state of the thread.
        public func set<DataType>(_ flavor: Mach.ThreadStateFlavor, to value: DataType) throws
        where DataType: BitwiseCopyable {
            try Mach.callWithCountIn(value: value) {
                (array: thread_state_t, count) in
                thread_set_state(self.thread.name, flavor.rawValue, array, count)
            }
        }
    }
}

extension Mach.Thread {
    /// The thread's state.
    public var state: Mach.ThreadStateManager { Mach.ThreadStateManager(thread: self) }
}

// MARK: - Thread State Getters and Setters (Specific)
#if arch(arm) || arch(arm64)
    extension Mach.ThreadStateManager {
        // General states

        /// The ARM state of the thread (32-bit).
        public var armState32: arm_thread_state32_t {
            get throws { try self.get(.arm32) }
        }

        /// Sets the ARM state of the thread (32-bit).
        public func setARMState32(to value: arm_thread_state32_t) throws {
            try self.set(.arm32, to: value)
        }

        /// The ARM state of the thread (64-bit).
        public var armState64: arm_thread_state64_t {
            get throws { try self.get(.arm64) }
        }

        /// Sets the ARM state of the thread (64-bit).
        public func setARMState64(to value: arm_thread_state64_t) throws {
            try self.set(.arm64, to: value)
        }

        // Exception states

        /// The ARM exception state of the thread (32-bit).
        public var armExceptionState32: arm_exception_state32_t {
            get throws { try self.get(.armException32) }
        }

        /// Sets the ARM exception state of the thread (32-bit).
        public func setARMExceptionState32(to value: arm_exception_state32_t) throws {
            try self.set(.armException32, to: value)
        }

        /// The ARM exception state of the thread (64-bit).
        public var armExceptionState64: arm_exception_state64_t {
            get throws { try self.get(.armException64) }
        }

        /// Sets the ARM exception state of the thread (64-bit).
        public func setARMExceptionState64(to value: arm_exception_state64_t) throws {
            try self.set(.armException64, to: value)
        }

        // Debug states

        /// The ARM debug state of the thread (32-bit).
        public var armDebugState32: arm_debug_state32_t {
            get throws { try self.get(.armDebug32) }
        }

        /// Sets the ARM debug state of the thread (32-bit).
        public func setARMDebugState32(to value: arm_debug_state32_t) throws {
            try self.set(.armDebug32, to: value)
        }

        /// The legacy (pre-Armv8) ARM debug state of the thread (32-bit).
        public var armDebugState32Legacy: arm_debug_state_t {
            get throws { try self.get(.armDebugLegacy) }
        }

        /// Sets the legacy (pre-Armv8) ARM debug state of the thread (32-bit).
        public func setARMDebugState32Legacy(to value: arm_debug_state_t) throws {
            try self.set(.armDebugLegacy, to: value)
        }

        /// The ARM debug state of the thread (64-bit).
        public var armDebugState64: arm_debug_state64_t {
            get throws { try self.get(.armDebug64) }
        }

        /// Sets the ARM debug state of the thread (64-bit).
        public func setARMDebugState64(to value: arm_debug_state64_t) throws {
            try self.set(.armDebug64, to: value)
        }

        /// Non-bit-width-specific states

        /// The ARM VFP state of the thread.
        public var armVFPState: arm_vfp_state_t {
            get throws { try self.get(.armVFP) }
        }

        /// Sets the ARM VFP state of the thread.
        public func setARMVFPState(to value: arm_vfp_state_t) throws {
            try self.set(.armVFP, to: value)
        }

        /// The ARM page-in state of the thread.
        public var armPageInState: arm_pagein_state_t {
            get throws { try self.get(.armPageIn) }
        }
    }
#elseif arch(i386) || arch(x86_64)
    extension Mach.ThreadStateManager {
        // General states

        /// The x86 state of the thread (32-bit).
        public var x86State32: x86_thread_state32_t {
            get throws { try self.get(.x86_32) }
        }

        /// Sets the x86 state of the thread (32-bit).
        public func setX86State32(to value: x86_thread_state32_t) throws {
            try self.set(.x86_32, to: value)
        }

        /// The x86 state of the thread (64-bit).
        public var x86State64: x86_thread_state64_t {
            get throws { try self.get(.x86_64) }
        }

        /// Sets the x86 state of the thread (64-bit).
        public func setX86State64(to value: x86_thread_state64_t) throws {
            try self.set(.x86_64, to: value)
        }

        /// The full 64-bit x86 state of the thread.
        public var x86FullState64: x86_thread_full_state64_t {
            get throws { try self.get(.x86Full64) }
        }

        /// Sets the full 64-bit x86 state of the thread.
        public func setX86FullState64(to value: x86_thread_full_state64_t) throws {
            try self.set(.x86Full64, to: value)
        }

        // Exception states

        /// The x86 exception state of the thread (32-bit).
        public var x86ExceptionState32: x86_exception_state32_t {
            get throws { try self.get(.x86Exception32) }
        }

        /// The x86 exception state of the thread (64-bit).
        public var x86ExceptionState64: x86_exception_state64_t {
            get throws { try self.get(.x86Exception64) }
        }

        // Debug states

        /// The x86 debug state of the thread (32-bit).
        public var x86DebugState32: x86_debug_state32_t {
            get throws { try self.get(.x86Debug32) }
        }

        /// Sets the x86 debug state of the thread (32-bit).
        public func setX86DebugState32(to value: x86_debug_state32_t) throws {
            try self.set(.x86Debug32, to: value)
        }

        /// The x86 debug state of the thread (64-bit).
        public var x86DebugState64: x86_debug_state64_t {
            get throws { try self.get(.x86Debug64) }
        }

        /// Sets the x86 debug state of the thread (64-bit).
        public func setX86DebugState64(to value: x86_debug_state64_t) throws {
            try self.set(.x86Debug64, to: value)
        }

        // FIXME: Floating-point state structs are not properly bridged for x86 (or rather, they
        // don't conform to `BitwiseCopyable`, which is an indication that they are not properly
        // bridged).
        // // Floating-point states

        // /// The 32-bit x86 floating-point state of the thread.
        // public var x86FloatState32: x86_float_state32_t {
        //     get throws { try self.get(.x86Float32) }
        // }

        // /// The 64-bit x86 floating-point state of the thread.
        // public var x86FloatState64: x86_float_state64_t {
        //     get throws { try self.get(.x86Float64) }
        // }

        // FIXME: x86 AVX state structs are not properly bridged (or rather, they don't conform
        // to `BitwiseCopyable`, which is an indication that they are not properly bridged).
        // // AVX states

        // /// The x86 debug AVX of the thread (32-bit).
        // public var x86AVXState32: x86_avx_state32_t {
        //     get throws { try self.get(.x86AVX32) }
        // }

        // /// The x86 debug AVX of the thread (64-bit).
        // public var x86AVXState64: x86_avx_state64_t {
        //     get throws { try self.get(.x86AVX64) }
        // }

        // Non-bit-width-specific states

        /// The x86 page-in state of the thread.
        public var x86PageInState: x86_pagein_state_t {
            get throws { try self.get(.x86PageIn) }
        }

        /// The x86 instruction state of the thread.
        public var x86InstructionState: x86_instruction_state_t {
            get throws { try self.get(.x86Instruction) }
        }

        // FIXME: The `x86_last_branch_state_t` type cannot be found when building
        // for x86_64. Also, the underlying `__last_branch_state` structure is not
        // bridged properly (or rather, it doesn't conform to `BitwiseCopyable`).
        // /// The x86 last branch record state of the thread.
        // public var x86LastBranchState: x86_last_branch_state_t {
        //     get throws { try self.get(.x86LastBranch) }
        // }
    }
#endif

// MARK: - Thread State Getters and Setters (Convenience)
extension Mach.ThreadStateManager {

    #if arch(arm)
        /// The general state of the thread.
        public var generalState: arm_thread_state32_t {
            get throws { try self.armState32 }
        }

        /// Sets the general state of the thread.
        public func setGeneralState(to value: arm_thread_state32_t) throws {
            try self.setARMState32(to: value)
        }
    #elseif arch(arm64)
        /// The general state of the thread.
        public var generalState: arm_thread_state64_t {
            get throws { try self.armState64 }
        }

        /// Sets the general state of the thread.
        public func setGeneralState(to value: arm_thread_state64_t) throws {
            try self.setARMState64(to: value)
        }
    #elseif arch(i386)
        /// The general state of the thread.
        public var generalState: x86_thread_state32_t {
            get throws { try self.x86State32 }
        }

        /// Sets the general state of the thread.
        public func setGeneralState(to value: x86_thread_state32_t) throws {
            try self.setX86State32(to: value)
        }
    #elseif arch(x86_64)
        /// The general state of the thread.
        public var generalState: x86_thread_state64_t {
            get throws { try self.x86State64 }
        }

        /// Sets the general state of the thread.
        public func setGeneralState(to value: x86_thread_state64_t) throws {
            try self.setX86State64(to: value)
        }
    #endif

    #if arch(arm)
        /// The exception state of the thread.
        public var exceptionState: arm_exception_state32_t {
            get throws { try self.armExceptionState32 }
        }

        /// Sets the exception state of the thread.
        public func setExceptionState(to value: arm_exception_state32_t) throws {
            try self.setARMExceptionState32(to: value)
        }
    #elseif arch(arm64)
        /// The exception state of the thread.
        public var exceptionState: arm_exception_state64_t {
            get throws { try self.armExceptionState64 }
        }

        /// Sets the exception state of the thread.
        public func setExceptionState(to value: arm_exception_state64_t) throws {
            try self.setARMExceptionState64(to: value)
        }
    #elseif arch(i386)
        /// The exception state of the thread.
        public var exceptionState: x86_exception_state32_t {
            get throws { try self.x86ExceptionState32 }
        }

        /// Sets the exception state of the thread.
        /// - Warning: This does nothing on x86. It is only here for API consistency.
        public func setExceptionState(to value: x86_exception_state32_t) throws {
            try self.set(.x86Exception32, to: value)
        }
    #elseif arch(x86_64)
        /// The exception state of the thread.
        public var exceptionState: x86_exception_state64_t {
            get throws { try self.x86ExceptionState64 }
        }

        /// Sets the exception state of the thread.
        /// - Warning: This does nothing on x86_64. It is only here for API consistency.
        public func setExceptionState(to value: x86_exception_state64_t) throws {
            try self.set(.x86Exception64, to: value)
        }
    #endif

    #if arch(arm)
        /// The debug state of the thread.
        public var debugState: arm_debug_state32_t {
            get throws { try self.armDebugState32 }
        }

        /// Sets the debug state of the thread.
        public func setDebugState(to value: arm_debug_state32_t) throws {
            try self.setARMDebugState32(to: value)
        }
    #elseif arch(arm64)
        /// The debug state of the thread.
        public var debugState: arm_debug_state64_t {
            get throws { try self.armDebugState64 }
        }

        /// Sets the debug state of the thread.
        public func setDebugState(to value: arm_debug_state64_t) throws {
            try self.setARMDebugState64(to: value)
        }
    #elseif arch(i386)
        /// The debug state of the thread.
        public var debugState: x86_debug_state32_t {
            get throws { try self.x86DebugState32 }
        }

        /// Sets the debug state of the thread.
        public func setDebugState(to value: x86_debug_state32_t) throws {
            try self.setX86DebugState32(to: value)
        }
    #elseif arch(x86_64)
        /// The debug state of the thread.
        public var debugState: x86_debug_state64_t {
            get throws { try self.x86DebugState64 }
        }

        /// Sets the debug state of the thread.
        public func setDebugState(to value: x86_debug_state64_t) throws {
            try self.setX86DebugState64(to: value)
        }
    #endif

    #if arch(arm) || arch(arm64)
        /// The floating-point state of the thread.
        public var floatState: arm_vfp_state_t {
            get throws { try self.armVFPState }
        }
    // FIXME: Floating-point state structs are not properly bridged for x86 (or rather, they
    // don't conform to `BitwiseCopyable`, which is an indication that they are not properly
    // bridged).
    // #elseif arch(i386)
    //     /// The floating-point state of the thread.
    //     public var floatState: x86_float_state32_t {
    //         get throws { try self.x86FloatState32 }
    //     }
    // #elseif arch(x86_64)
    //     /// The floating-point state of the thread.
    //     public var floatState: x86_float_state64_t {
    //         get throws { try self.x86FloatState64 }
    //     }
    #endif

    // FIXME: x86 AVX state structs are not properly bridged (or rather, they don't conform
    // to `BitwiseCopyable`, which is an indication that they are not properly bridged).
    // #if arch(i386)
    //     /// The AVX state of the thread.
    //     public var avxState: x86_avx_state32_t {
    //         get throws { try self.x86AVXState32 }
    //     }
    // #elseif arch(x86_64)
    //     /// The AVX state of the thread.
    //     public var avxState: x86_avx_state64_t {
    //         get throws { try self.x86AVXState64 }
    //     }
    // #endif

    #if arch(arm) || arch(arm64)
        /// The page-in state of the thread.
        public var pageInState: arm_pagein_state_t {
            get throws { try self.armPageInState }
        }
    #elseif arch(i386) || arch(x86_64)
        /// The page-in state of the thread.
        public var pageInState: x86_pagein_state_t {
            get throws { try self.x86PageInState }
        }
    #endif
}

// MARK: - Task Default Thread State Getters and Setter
extension Mach.Task {
    /// Gets the default state inherited by new threads created in the task.
    public func getDefaultThreadState<DataType: BitwiseCopyable>(
        _ flavor: Mach.ThreadStateFlavor, as type: DataType.Type = DataType.self
    ) throws -> DataType {
        try Mach.callWithCountInOut(type: type) {
            (array: thread_state_t, count) in
            task_get_state(self.name, flavor.rawValue, array, &count)
        }
    }

    /// Sets the default state to be inherited by new threads created in the task.
    public func setDefaultThreadState<DataType: BitwiseCopyable>(
        _ flavor: Mach.ThreadStateFlavor, to value: DataType
    ) throws {
        try Mach.callWithCountIn(value: value) {
            array, count in
            task_set_state(self.name, flavor.rawValue, array, count)
        }
    }

    /// Clears the default state to be inherited by new threads created in the task.
    public func clearDefaultThreadState() throws {
        try setDefaultThreadState(.none, to: ())
    }
}
