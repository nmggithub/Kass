import Darwin.Mach

extension Mach.Task {
    // The task's policy.
    public var policy: Policy { Policy(of: self) }
    // A task's policy.
    public class Policy: Mach.FlavoredDataManager<
        Policy.Flavor, task_policy_t.Pointee,
        UnsafeMutablePointer<boolean_t>?, Never?
    >
    {
        /// Get a task's policy.
        /// - Parameter task: The task.
        public convenience init(of task: Mach.Task) {
            self.init(
                getter: { flavor, array, count, getDefault in
                    return task_policy_get(task.name, flavor.rawValue, array, &count, getDefault)
                },
                setter: { flavor, array, count, _ in
                    task_policy_set(task.name, flavor.rawValue, array, count)
                }
            )
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
            var get_default: boolean_t = getDefault ? 1 : 0
            return try super.get(flavor, as: PolicyType.self, additional: &get_default)
        }
    }

}
