import Darwin.Mach

extension Mach {
    /// A set of processors in a host.
    public class ProcessorSet: Mach.Port {
        /// The host that the processor is in.
        public let owningHost: Mach.Host

        /// Represents an processor set existing in a host.
        public init(named name: processor_set_t, in host: Mach.Host) {
            self.owningHost = host
            super.init(named: name)
        }

        @available(*, unavailable, message: "Use the host-based `init(named:in:)` instead.")
        required init(named name: mach_port_name_t, in task: Mach.Task = .current) {
            self.owningHost = Mach.Host.current
            super.init(named: name, in: task)
        }

        /// Gets the default processor set for a host.
        public static func `default`(in host: Mach.Host = .current) throws -> ProcessorSet {
            var name = processor_set_name_t()
            try Mach.call(processor_set_default(host.name, &name))
            return ProcessorSet(named: name, in: host)
        }

        /// The processor set's control port.
        public var controlPort: ProcessorSetControl {
            get throws {
                var controlPortName = mach_port_name_t()
                try Mach.call(
                    host_processor_set_priv(self.owningHost.name, self.name, &controlPortName)
                )
                return ProcessorSetControl(named: controlPortName)
            }
        }
    }
}

extension Mach.Host {
    /// The processor sets in the host.
    /// - Warning: This returns the name ports for the processor sets. Use `.controlPort`
    /// to get the control port for a processor set from its name port.
    public var processorSets: [Mach.ProcessorSet] {
        get throws {
            var processorSetList: processor_set_name_array_t?
            var processorSetCount = mach_msg_type_number_t.max
            try Mach.call(host_processor_sets(self.name, &processorSetList, &processorSetCount))
            return (0..<Int(processorSetCount)).map {
                Mach.ProcessorSet(named: processorSetList![$0], in: self)
            }
        }
    }
}
