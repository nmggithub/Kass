import Darwin.Mach
@_exported import MachHost

extension Mach.Host {
    /// A processor in a host.
    public class Processor: Mach.Port {
        /// The host that the processor is in.
        public var owningHost: Mach.Host

        /// Represent an processor existing in a host.
        /// - Parameters:
        ///   - name: The port name for the processor.
        ///   - host: The host that the processor is in.
        public init(named name: processor_t, in host: Mach.Host) {
            self.owningHost = host
            super.init(named: name)
        }

        /// Represent an existing processor in the current host.
        /// - Parameter name: The port name for the processor.
        required init(named name: mach_port_name_t) {
            self.owningHost = Mach.Host.current
            super.init(named: name)
        }

        /// Start the processor.
        /// - Throws: An error if the processor cannot be started.
        public func start() throws { try Mach.call(processor_start(self.name)) }
        /// Stop the processor.
        /// - Throws: An error if the processor cannot be stopped.
        public func exit() throws { try Mach.call(processor_exit(self.name)) }
    }
    /// The processors in the host.
    public var processors: [Processor] {
        get throws {
            var processorList: processor_array_t?
            var processorCount = mach_msg_type_number_t.max
            try Mach.call(host_processors(self.name, &processorList, &processorCount))
            return (0..<Int(processorCount)).map {
                Processor(named: processorList![$0], in: self)
            }
        }
    }
}
