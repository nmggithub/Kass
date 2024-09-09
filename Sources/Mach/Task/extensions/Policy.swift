import Darwin.Mach
import Foundation.NSError

extension Mach.Task {
    // The task's policy.
    public var policy: Policy { Policy(of: self) }
    // A task's policy.
    public struct Policy {
        /// The task to get the policy of.
        public let task: Mach.Task
        /// Get a task's policy.
        /// - Parameter task: The task.
        public init(of task: Mach.Task) {
            self.task = task
        }
        /// A flavor of task policy.
        public enum Flavor: task_policy_flavor_t {
            case category = 1
            case suppression = 3
            case state = 4
            case baseQoS = 8
            case overrideQoS = 9
            case latencyQoS = 10
            case throughputQoS = 11
        }

        /// Get a task's policy.
        /// - Parameters:
        ///   - flavor: The flavor of the policy.
        ///   - type: The type to load the policy as.
        ///   - default: Whether to get the default value of the policy.
        /// - Throws: An error if the policy cannot be retrieved.
        public func get<PolicyType>(
            _ flavor: Flavor, as type: PolicyType.Type, getDefault: Bool = false
        ) throws -> PolicyType {
            var count = mach_msg_type_number_t(
                MemoryLayout<PolicyType>.size / MemoryLayout<task_policy_t.Pointee>.size
            )
            let arrayPointer = task_policy_t.allocate(capacity: Int(copy count))
            defer { arrayPointer.deallocate() }
            let get_default = UnsafeMutablePointer<boolean_t>.allocate(capacity: 1)
            get_default.pointee = getDefault ? 1 : 0
            try Mach.Syscall(
                task_policy_get(
                    self.task.name, flavor.rawValue, arrayPointer, &count,
                    get_default
                ))
            return UnsafeMutableRawPointer(arrayPointer).load(as: PolicyType.self)
        }
        /// Get a task's policy.
        /// - Parameters:
        ///   - flavor: The flavor of the policy.
        ///   - count: The size of the policy, in `integer_t`'s.
        ///   - default: Whether to get the default value of the policy.
        /// - Throws: An error if the policy cannot be retrieved.
        /// - Returns: A pointer to a variable-length array containing the policy.
        /// - Important: This function is for advanced use only. ``get(_:as:getDefault:)`` is recommended.
        /// - Warning: The caller is responsible for deallocating the returned pointer.
        public func get(
            _ flavor: Flavor,
            count: consuming mach_msg_type_number_t = mach_msg_type_number_t.max,
            getDefault: Bool = false
        ) throws -> task_policy_t {
            let valuePointer = task_policy_t.allocate(capacity: Int(copy count))
            let get_default = UnsafeMutablePointer<boolean_t>.allocate(capacity: 1)
            get_default.pointee = getDefault ? 1 : 0
            let ret = task_policy_get(
                self.task.name, flavor.rawValue, valuePointer, &count, get_default
            )
            guard ret == KERN_SUCCESS else {
                throw NSError(domain: NSMachErrorDomain, code: Int(ret))
            }
            return valuePointer
        }
    }

}
