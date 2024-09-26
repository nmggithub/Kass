import Darwin.Mach
@_exported import MachCore

extension Mach {
    /// A processor in a host.
    public class Processor: Mach.Port {
        /// The host that the processor is in.
        public let owningHost: Mach.Host

        /// Represents an processor existing in a host.
        public init(named name: processor_t, inHost host: Mach.Host) {
            self.owningHost = host
            super.init(named: name)
        }

        @available(*, unavailable, message: "Use `init(named:inHost:)` instead.")
        required init(named name: mach_port_name_t, inNameSpaceOf task: Mach.Task = .current) {
            self.owningHost = Mach.Host.current
            super.init(named: name, inNameSpaceOf: task)
        }

        /// Starts the processor.
        public func start() throws { try Mach.call(processor_start(self.name)) }

        /// Stops the processor.
        public func exit() throws { try Mach.call(processor_exit(self.name)) }

        /// The processor set that the processor is in.
        public var assignment: Mach.ProcessorSet {
            get throws {
                var processorSet = processor_set_name_t()
                try Mach.call(processor_get_assignment(self.name, &processorSet))
                return Mach.ProcessorSet(named: processorSet, inHost: owningHost)
            }
        }
    }
}

extension Mach.Host {
    /// The processors in the host.
    public var processors: [Mach.Processor] {
        get throws {
            var processorList: processor_array_t?
            var processorCount = mach_msg_type_number_t.max
            try Mach.call(host_processors(self.name, &processorList, &processorCount))
            return (0..<Int(processorCount)).map {
                Mach.Processor(named: processorList![$0], inHost: self)
            }
        }
    }
}
