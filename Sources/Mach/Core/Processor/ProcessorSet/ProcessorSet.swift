import Darwin.Mach

extension Mach {
    /// A set of processors in a host.
    public class ProcessorSet: Mach.Port {
        /// The host that the processor is in.
        public let owningHost: Mach.Host

        /// Represents an processor set existing in a host.
        public init(named name: processor_set_t, inHost host: Mach.Host) {
            self.owningHost = host
            super.init(named: name)
        }

        @available(*, unavailable, message: "Use `init(named:inHost:)` instead.")
        required init(named name: mach_port_name_t, inNameSpaceOf task: Mach.Task = .current) {
            self.owningHost = Mach.Host.current
            super.init(named: name, inNameSpaceOf: task)
        }

        /// Gets the default processor set for a host.
        public static func `default`(inHost host: Mach.Host = .current) throws -> ProcessorSet {
            var name = processor_set_name_t()
            try Mach.call(processor_set_default(host.name, &name))
            return ProcessorSet(named: name, inHost: host)
        }

        /// The processor set's control port.
        public var controlPort: ProcessorSetControl {
            get throws {
                var controlPortName = mach_port_name_t()
                try Mach.call(
                    host_processor_set_priv(self.owningHost.name, self.name, &controlPortName)
                )
                return ProcessorSetControl(named: controlPortName, inNameSpaceOf: .current)
            }
        }
    }
}

extension Mach.Host {
    /// The processor sets in the host.
    public var processorSets: [Mach.ProcessorSet] {
        get throws {
            var processorSetList: processor_set_name_array_t?
            var processorSetCount = mach_msg_type_number_t.max
            try Mach.call(host_processor_sets(self.name, &processorSetList, &processorSetCount))
            return (0..<Int(processorSetCount)).map {
                Mach.ProcessorSet(named: processorSetList![$0], inHost: self)
            }
        }
    }
}
