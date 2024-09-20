import Darwin.Mach

extension Mach.Task.InspectPort {
    /// The task's inspect.
    public var inspectInfo: InspectInfo { InspectInfo(about: self) }
    /// A task's inspect.
    public class InspectInfo: Mach.FlavoredDataManagerNoAdditionalArgs<
        InspectInfo.Flavor, task_inspect_info_t.Pointee
    >
    {
        /// Creates a task inspect info manager.
        /// - Parameter task: The task to manage inspect info about.
        public convenience init(about task: Mach.Task.InspectPort) {
            self.init(
                getter: { flavor, array, count, _ in
                    task_inspect(task.name, flavor.rawValue, array, &count)
                },
                setter: { flavor, array, count, _ in
                    fatalError("Task inspect info cannot be set.")
                }
            )
        }
        /// A flavor of task inspect.
        public enum Flavor: task_inspect_flavor_t {
            case basicCounts = 1
        }
    }
}
