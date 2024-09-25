import Darwin.Mach

extension Mach.Processor {
    /// Controls the processor.
    /// - Parameter info: The information to control the processor with.
    /// - Warning: It seems this is not implemented in XNU, but is still inherited from Mach.
    public func control<InfoType: BitwiseCopyable>(_ info: InfoType) throws {
        try Mach.callWithCountIn(value: info) {
            array, count in
            processor_control(self.name, array, count)
        }
    }
}
