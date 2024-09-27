import Darwin.Mach

extension Mach.Thread {
    /// A flavor of thread (port).
    public enum Flavor: mach_thread_flavor_t {
        /// A thread control port.
        case control = 0

        /// A thread read port.
        case read = 1

        /// A thread name port.
        case inspect = 2
    }
    /// A thread (port) with a flavor.
    public protocol Flavored: Mach.Thread {
        /// The flavor of the thread port.
        var flavor: Mach.Thread.Flavor { get }
    }
}

extension Mach {
    /// A thread's control port.
    public class ThreadControl: Mach.Thread, Mach.Thread.Flavored {
        /// The ``Mach/Thread/Flavor/control`` flavor.
        public let flavor: Mach.Thread.Flavor = .control

        /// A nil Thread control port.
        override public class var Nil: Self {
            Self(named: mach_port_name_t(THREAD_NULL))
        }
    }

    /// A thread's read port.
    public class ThreadRead: Mach.Thread, Mach.Thread.Flavored {
        /// The ``Mach/Thread/Flavor/read`` flavor.
        public let flavor: Mach.Thread.Flavor = .read

        /// A nil thread read port.
        override public class var Nil: Self {
            Self(named: mach_port_name_t(THREAD_READ_NULL))
        }
    }

    /// A Thread's inspect port.
    public class ThreadInspect: Mach.Thread, Mach.Thread.Flavored {
        /// The ``Mach/Thread/Flavor/inspect`` flavor.
        public let flavor: Mach.Thread.Flavor = .inspect

        /// A nil Thread inspect port.
        override public class var Nil: Self {
            Self(named: mach_port_name_t(THREAD_INSPECT_NULL))
        }
    }
}
