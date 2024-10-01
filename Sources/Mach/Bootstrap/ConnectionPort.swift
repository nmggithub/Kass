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
    /// A connection port.
    public class ConnectionPort: Mach.Port {
        /// Constructs a connection port.
        public static func construct(
            servicePort: Mach.ServicePort,
            context: mach_port_context_t? = nil,
            inNameSpaceOf task: Mach.Task = .current,
            limits: mach_port_limits_t = mach_port_limits_t(),
            flags: consuming Set<Mach.PortConstructFlag> = []
        ) throws -> Self {
            flags.insert(.connectionPort)
            var options = mach_port_options_t()
            options.service_port_name = servicePort.name
            options.mpl = limits
            options.flags = UInt32(flags.bitmap())
            return try Self.construct(options: options, context: context, inNameSpaceOf: task)
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
