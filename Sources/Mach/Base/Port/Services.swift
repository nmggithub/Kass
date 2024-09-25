import Darwin.Mach
import Linking

let mach_port_is_connection_for_service:
    @convention(c) (
        _ task: task_t, _ connection_port_name: mach_port_name_t,
        _ service_port_name: mach_port_name_t,
        _ filter_policy_id: UnsafePointer<UInt64>
    )
        -> kern_return_t = libSystem().get(symbol: "mach_port_is_connection_for_service")!.cast()

extension Mach {
    /// A service port.
    public class ServicePort: Mach.Port {
        /// Constructs a service port.
        /// - Important: This is only allowed for the init system.
        public convenience init(
            _ serviceName: String, domainType: UInt8,
            context: mach_port_context_t? = nil,
            in task: Mach.Task = .current,
            limits: mach_port_limits_t = mach_port_limits_t(),
            flags: consuming Set<ConstructFlag> = []
        ) throws {
            guard serviceName.count <= MACH_SERVICE_PORT_INFO_STRING_NAME_MAX_BUF_LEN else {
                fatalError("Service name is too long.")
            }
            flags.insert(.servicePort)
            let servicePortInfoPointer = mach_service_port_info_t.allocate(capacity: 1)
            servicePortInfoPointer.pointer(to: \.mspi_string_name)?.withMemoryRebound(
                to: CChar.self, capacity: Int(MACH_SERVICE_PORT_INFO_STRING_NAME_MAX_BUF_LEN)
            ) { let _ = strcpy($0, serviceName) }
            var options = mach_port_options_t()
            options.service_port_info = servicePortInfoPointer
            options.mpl = limits
            options.flags = flags.bitmap()
            try self.init(options: options, context: context, in: task)
        }

        /// If the service port is throttled.
        public var isThrottled: Bool {
            get throws { try self.getAttribute(.throttled, as: boolean_t.self) == 1 }
        }

        /// Sets the service port throttling status.
        public func setIsThrottled(to value: Bool) throws {
            try self.setAttribute(.throttled, to: value ? 1 : 0)
        }
    }
}

extension Mach {
    /// A connection port.
    public class ConnectionPort: Mach.Port {
        /// Constructs a connection port.
        public convenience init(
            for servicePort: Mach.ServicePort,
            context: mach_port_context_t? = nil,
            in task: Mach.Task = .current,
            limits: mach_port_limits_t = mach_port_limits_t(),
            flags: consuming Set<ConstructFlag> = []
        ) throws {
            flags.insert(.connectionPort)
            var options = mach_port_options_t()
            options.service_port_name = servicePort.name
            options.mpl = limits
            options.flags = flags.bitmap()
            try self.init(options: options, context: context, in: task)
        }

        /// Determines if the connection port is for a service and returns the filter policy ID.
        public func isForService(_ servicePort: Mach.ServicePort) throws -> UInt64 {
            var filterPolicyID = UInt64()
            try Mach.call(
                mach_port_is_connection_for_service(
                    self.owningTask.name, self.name, servicePort.name, &filterPolicyID
                )
            )
            return filterPolicyID
        }
    }
}
