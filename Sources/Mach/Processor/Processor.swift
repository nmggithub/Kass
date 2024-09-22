import Darwin.Mach
@_exported import MachHost

extension Mach.Host {
    /// A processor in a host.
    public class Processor: Mach.Port {
        /// The host that the processor is in.
        public var owningHost: Mach.Host

        /// Represents an processor existing in a host.
        /// - Parameters:
        ///   - name: The port name for the processor.
        ///   - host: The host that the processor is in.
        public init(named name: processor_t, in host: Mach.Host) {
            self.owningHost = host
            super.init(named: name)
        }

        @available(*, unavailable, message: "Use the host-based `init(named:in:)` instead.")
        required init(named name: mach_port_name_t, in task: Mach.Task = .current) {
            self.owningHost = Mach.Host.current
            super.init(named: name, in: task)
        }

        /// Starts the processor.
        /// - Throws: An error if the processor cannot be started.
        public func start() throws { try Mach.call(processor_start(self.name)) }
        /// Stops the processor.
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
