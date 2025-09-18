#if arch(i386) || arch(x86_64)
    import Darwin.Mach
    import KassC.i386ThreadStatus

    extension Mach.ThreadState {
        /// x86 saved state (32-bit).
        public static func x86SavedState32(_ state: x86_saved_state32_t?)
            -> ThreadState<x86_saved_state32_t>
        { .init(flavorKey: x86_SAVED_STATE, data: state) }

        /// x86 saved state (64-bit).
        public static func x86SavedState64(_ state: x86_saved_state64_t?)
            -> ThreadState<x86_saved_state64_t>
        { .init(flavorKey: x86_SAVED_STATE64, data: state) }
    }
#endif
