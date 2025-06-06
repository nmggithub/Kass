import Darwin
import Foundation

extension Mach {
    /// A flavor of thread state, optionally with paired data.
    public struct ThreadState<StateDataType: BitwiseCopyable>: FlavorWithOptionalData {
        /// The type of the state data.
        public typealias DataType = StateDataType

        /// The thread state flavor key.
        public var flavorKey: thread_state_flavor_t

        /// The optional state data.
        public var data: DataType?

        /// Compares a raw flavor key with an instance of ``Mach/ThreadState``.
        /// - Important: This only returns true if the flavor key matches and there is no paired data.
        public static func == (lhs: thread_state_flavor_t, rhs: ThreadState) -> Bool {
            lhs == rhs.flavorKey && rhs.data == nil
        }

        /// Initializes a representation of a thread state flavor, optionally with paired data.
        init(flavorKey: thread_state_flavor_t, data: DataType? = nil) {
            self.flavorKey = flavorKey
            self.data = data
        }

        /// No thread state.
        public static var none: ThreadState<()> {
            .init(flavorKey: THREAD_STATE_NONE, data: nil)
        }

        #if arch(arm) || arch(arm64)

            /// ARM state (32-bit).
            public static func arm32(_ state: arm_thread_state32_t)
                -> ThreadState<arm_thread_state32_t>
            { .init(flavorKey: ARM_THREAD_STATE, data: state) }

            /// ARM state (32-bit).
            public static var arm32: ThreadState<arm_thread_state32_t> {
                .init(flavorKey: ARM_THREAD_STATE, data: nil)
            }

            /// ARM state (64-bit).
            public static func arm64(_ state: arm_thread_state64_t)
                -> ThreadState<arm_thread_state64_t>
            { .init(flavorKey: ARM_THREAD_STATE64, data: state) }

            /// ARM state (64-bit).
            public static var arm64: ThreadState<arm_thread_state64_t> {
                .init(flavorKey: ARM_THREAD_STATE64, data: nil)
            }

            /// ARM exception state (32-bit).
            public static func arm32Exception(_ state: arm_exception_state32_t)
                -> ThreadState<arm_exception_state32_t>
            { .init(flavorKey: ARM_EXCEPTION_STATE, data: state) }

            /// ARM exception state (32-bit).
            public static var arm32Exception: ThreadState<arm_exception_state32_t> {
                .init(flavorKey: ARM_EXCEPTION_STATE, data: nil)
            }

            /// ARM exception state (64-bit).
            public static func arm64Exception(_ state: arm_exception_state64_t)
                -> ThreadState<arm_exception_state64_t>
            { .init(flavorKey: ARM_EXCEPTION_STATE64, data: state) }

            /// ARM exception state (64-bit).
            public static var arm64Exception: ThreadState<arm_exception_state64_t> {
                .init(flavorKey: ARM_EXCEPTION_STATE64, data: nil)
            }

            /// ARM exception state (64-bit, version 2).
            public static func arm64ExceptionV2(_ state: arm_exception_state64_v2_t)
                -> ThreadState<arm_exception_state64_v2_t>
            { .init(flavorKey: ARM_EXCEPTION_STATE64_V2, data: state) }

            /// ARM exception state (64-bit, version 2).
            public static var arm64ExceptionV2: ThreadState<arm_exception_state64_v2_t> {
                .init(flavorKey: ARM_EXCEPTION_STATE64_V2, data: nil)
            }

            /// ARM debug state (32-bit, pre-ARMv8).
            public static func arm32DebugLegacy(_ state: arm_debug_state_t)
                -> ThreadState<arm_debug_state_t>
            { .init(flavorKey: ARM_DEBUG_STATE, data: state) }

            /// ARM debug state (32-bit, pre-ARMv8).
            public static var arm32DebugLegacy: ThreadState<arm_debug_state_t> {
                .init(flavorKey: ARM_DEBUG_STATE, data: nil)
            }

            /// ARM debug state (32-bit).
            public static func arm32Debug(_ state: arm_debug_state32_t)
                -> ThreadState<arm_debug_state32_t>
            { .init(flavorKey: ARM_DEBUG_STATE32, data: state) }

            /// ARM debug state (32-bit).
            public static var arm32Debug: ThreadState<arm_debug_state32_t> {
                .init(flavorKey: ARM_DEBUG_STATE32, data: nil)
            }

            /// ARM debug state (64-bit).
            public static func arm64Debug(_ state: arm_debug_state64_t)
                -> ThreadState<arm_debug_state64_t>
            { .init(flavorKey: ARM_DEBUG_STATE64, data: state) }

            /// ARM debug state (64-bit).
            public static var arm64Debug: ThreadState<arm_debug_state64_t> {
                .init(flavorKey: ARM_DEBUG_STATE64, data: nil)
            }

            /// ARM page-in state.
            public static func armPageIn(_ state: arm_pagein_state_t)
                -> ThreadState<arm_pagein_state_t>
            { .init(flavorKey: ARM_PAGEIN_STATE, data: state) }

            /// ARM page-in state.
            public static var armPageIn: ThreadState<arm_pagein_state_t> {
                .init(flavorKey: ARM_PAGEIN_STATE, data: nil)
            }

            /// ARM VFP state.
            public static func armVFP(_ state: arm_vfp_state_t)
                -> ThreadState<arm_vfp_state_t>
            { .init(flavorKey: ARM_VFP_STATE, data: state) }

            /// ARM VFP state.
            public static var armVFP: ThreadState<arm_vfp_state_t> {
                .init(flavorKey: ARM_VFP_STATE, data: nil)
            }

        // TODO: Uncomment these when Swift finally supports these types
        // /// ARM NEON state (32-bit).
        // public static func armNEON(_ state: arm_neon_state32_t)
        //     -> ThreadState<arm_neon_state32_t>
        // { .init(flavorKey: ARM_NEON_STATE, data: state) }
        //
        // /// ARM NEON state (32-bit).
        // public static var armNEON: ThreadState<arm_neon_state32_t> {
        //     .init(flavorKey: ARM_NEON_STATE, data: nil)
        // }
        //
        // /// ARM NEON state (64-bit).
        // public static func arm64NEON(_ state: arm_neon_state64_t)
        //     -> ThreadState<arm_neon_state64_t>
        // { .init(flavorKey: ARM_NEON_STATE64, data: state) }
        //
        // /// ARM NEON state (64-bit).
        // public static var arm64NEON: ThreadState<arm_neon_state64_t> {
        //     .init(flavorKey: ARM_NEON_STATE64, data: nil)
        // }

        #elseif arch(i386) || arch(x86_64)
            /// x86 state (32-bit).
            public static func x86_32(_ state: x86_thread_state32_t)
                -> ThreadState<x86_thread_state32_t>
            { .init(flavorKey: x86_THREAD_STATE32, data: state) }

            /// x86 state (32-bit).
            public static var x86_32: ThreadState<x86_thread_state32_t> {
                .init(flavorKey: x86_THREAD_STATE32, data: nil)
            }

            /// x86 state (64-bit).
            public static func x86_64(_ state: x86_thread_state64_t)
                -> ThreadState<x86_thread_state64_t>
            { .init(flavorKey: x86_THREAD_STATE64, data: state) }

            /// x86 state (64-bit).
            public static var x86_64: ThreadState<x86_thread_state64_t> {
                .init(flavorKey: x86_THREAD_STATE64, data: nil)
            }

            /// x86 state (64-bit, full).
            public static func x86_64Full(_ state: x86_thread_full_state64_t)
                -> ThreadState<x86_thread_full_state64_t>
            { .init(flavorKey: x86_THREAD_FULL_STATE64, data: state) }

            /// x86 state (64-bit, full).
            public static var x86_64Full: ThreadState<x86_thread_full_state64_t> {
                .init(flavorKey: x86_THREAD_FULL_STATE64, data: nil)
            }

            /// x86 exception state (32-bit).
            public static func x86_32Exception(_ state: x86_exception_state32_t)
                -> ThreadState<x86_exception_state32_t>
            { .init(flavorKey: x86_EXCEPTION_STATE32, data: state) }

            /// x86 exception state (32-bit).
            public static var x86_32Exception: ThreadState<x86_exception_state32_t> {
                .init(flavorKey: x86_EXCEPTION_STATE32, data: nil)
            }

            /// x86 exception state (64-bit).
            public static func x86_64Exception(_ state: x86_exception_state64_t)
                -> ThreadState<x86_exception_state64_t>
            { .init(flavorKey: x86_EXCEPTION_STATE64, data: state) }

            /// x86 exception state (64-bit).
            public static var x86_64Exception: ThreadState<x86_exception_state64_t> {
                .init(flavorKey: x86_EXCEPTION_STATE64, data: nil)
            }

            // TODO: Uncomment these when Swift finally supports these types
            // /// x86 floating-point state (32-bit).
            // public static func x86_32FP(_ state: x86_float_state32_t)
            //     -> ThreadState<x86_float_state32_t>
            // { .init(flavorKey: x86_FLOAT_STATE32, data: state) }
            //
            // /// x86 floating-point state (32-bit).
            // public static var x86_32FP: ThreadState<x86_float_state32_t> {
            //     .init(flavorKey: x86_FLOAT_STATE32, data: state)
            // }
            //
            // /// x86 floating-point state (64-bit).
            // public static func x86_64FP(_ state: x86_float_state64_t)
            //     -> ThreadState<x86_float_state64_t>
            // { .init(flavorKey: x86_FLOAT_STATE64, data: state) }
            //
            // /// x86 floating-point state (64-bit).
            // public static var x86_64FP: ThreadState<x86_float_state64_t> {
            //     .init(flavorKey: x86_FLOAT_STATE64, data: nil)
            // }

            /// x86 debug state (32-bit).
            public static func x86_32Debug(_ state: x86_debug_state32_t)
                -> ThreadState<x86_debug_state32_t>
            { .init(flavorKey: x86_DEBUG_STATE32, data: state) }

            /// x86 debug state (32-bit).
            public static var x86_32Debug: ThreadState<x86_debug_state32_t> {
                .init(flavorKey: x86_DEBUG_STATE32, data: nil)
            }

            /// x86 debug state (64-bit).
            public static func x86_64Debug(_ state: x86_debug_state64_t)
                -> ThreadState<x86_debug_state64_t>
            { .init(flavorKey: x86_DEBUG_STATE64, data: state) }

            /// x86 debug state (64-bit).
            public static var x86_64Debug: ThreadState<x86_debug_state64_t> {
                .init(flavorKey: x86_DEBUG_STATE64, data: nil)
            }

            /// x86 page-in state.
            public static func x86PageIn(_ state: x86_pagein_state_t)
                -> ThreadState<x86_pagein_state_t>
            { .init(flavorKey: x86_PAGEIN_STATE, data: state) }

            /// x86 page-in state.
            public static var x86PageIn: ThreadState<x86_pagein_state_t> {
                .init(flavorKey: x86_PAGEIN_STATE, data: nil)
            }

            /// x86 instruction state.
            public static func x86Instruction(_ state: x86_instruction_state_t)
                -> ThreadState<x86_instruction_state_t>
            { .init(flavorKey: x86_INSTRUCTION_STATE, data: state) }

            /// x86 instruction state.
            public static var x86Instruction: ThreadState<x86_instruction_state_t> {
                .init(flavorKey: x86_INSTRUCTION_STATE, data: nil)
            }

        // TODO: Uncomment this when Swift finally supports this types
        // /// x86 last branch state.
        // public static func x86LastBranch(_ state: x86_last_branch_state_t)
        //     -> ThreadState<x86_last_branch_state_t>
        // { .init(flavorKey: x86_LAST_BRANCH_STATE, data: state) }
        //
        // /// x86 last branch state.
        // public static var x86LastBranch: ThreadState<x86_last_branch_state_t> {
        //     .init(flavorKey: x86_LAST_BRANCH_STATE, data: nil)
        // }

        #endif

    }
}

extension Mach.Thread {
    /// Gets state for the thread.
    /// - Warning: This call will fail if data is included in the state argument.
    public func getState<DataType>(_ state: Mach.ThreadState<DataType>) throws -> DataType {
        guard state.data == nil else { throw MachError(.invalidArgument) }
        return try Mach.callWithCountInOut(type: DataType.self) {
            (array: thread_state_t, count) in
            thread_get_state(self.name, state.flavorKey, array, &count)
        }
    }

    /// Sets state for the thread.
    /// - Warning: This call will fail if data is not included in the state argument.
    public func setState<DataType>(_ state: Mach.ThreadState<DataType>) throws {
        guard let value = state.data else { throw MachError(.invalidArgument) }
        try Mach.callWithCountIn(value: value) {
            (array: thread_state_t, count) in
            thread_set_state(self.name, state.flavorKey, array, count)
        }
    }
}

extension Mach.Task {
    /// Gets the default state for new threads in the task.
    /// - Warning: This call will fail if data is included in the state argument.
    public func getDefaultThreadState<DataType>(_ threadState: Mach.ThreadState<DataType>)
        throws -> DataType
    {
        guard threadState.data == nil else { throw MachError(.invalidArgument) }
        return try Mach.callWithCountInOut(type: DataType.self) {
            (array: thread_state_t, count) in
            task_get_state(self.name, threadState.flavorKey, array, &count)
        }
    }

    /// Sets the default state for new threads in the task.
    /// - Warning: This call will fail if data is not included in the state argument.
    public func setDefaultThreadState<DataType>(_ threadState: Mach.ThreadState<DataType>) throws {
        guard let value = threadState.data else { throw MachError(.invalidArgument) }
        try Mach.callWithCountIn(value: value) {
            (array: thread_state_t, count) in
            task_set_state(self.name, threadState.flavorKey, array, count)
        }
    }

    /// Clears the default thread state for the task.
    public func clearDefaultThreadState() throws {
        try Mach.callWithCountIn(value: ()) {
            (array: thread_state_t, count) in
            task_set_state(self.name, THREAD_STATE_NONE, array, count)
        }
    }
}
