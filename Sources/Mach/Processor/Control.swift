import Darwin.Mach

extension Mach.Host.Processor {
    #if swift(>=6.0)
        public typealias ControlInfoType = BitwiseCopyable
    #else
        public typealias ControlInfoType = Any
    #endif

    /// Control the processor.
    /// - Parameter info: The information to control the processor with.
    /// - Warning: It seems this is not implemented in XNU, but is still inherited from Mach.
    public func control<InfoType: ControlInfoType>(_ info: InfoType) throws {
        #if swift(<6)
            assert(
                _isPOD(Self.self),
                """
                Cannot use non-trivial control info type `\(InfoType.self)` with processor control.
                """
            )
        #endif
        try Mach.SyscallWithCountIn(
            arrayType: processor_info_t.self, data: info,
            syscall: {
                array, count in
                processor_control(self.name, array, count)
            }
        )
    }
}
