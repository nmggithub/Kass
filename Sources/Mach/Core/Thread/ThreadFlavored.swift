import Darwin.Mach

extension Mach {
    /// A flavor of thread (port).
    public enum ThreadFlavor: mach_thread_flavor_t {
        /// A thread control port.
        case control = 0

        /// A thread read port.
        case read = 1

        /// A thread name port.
        case inspect = 2
    }
    /// A thread (port) with a flavor.
    public protocol ThreadFlavored: Mach.Thread {
        /// The flavor of the thread port.
        var flavor: Mach.ThreadFlavor { get }
    }
}

extension Mach {
    /// A thread's control port.
    public class ThreadControl: Mach.Thread, Mach.ThreadFlavored {
        /// The ``Mach/ThreadFlavor/control`` flavor.
        public let flavor: Mach.ThreadFlavor = .control

        /// A nil Thread control port.
        override public class var Nil: Self {
            Self(named: mach_port_name_t(THREAD_NULL))
        }
    }

    /// A thread's read port.
    public class ThreadRead: Mach.Thread, Mach.ThreadFlavored {
        /// The ``Mach/ThreadFlavor/read`` flavor.
        public let flavor: Mach.ThreadFlavor = .read

        /// A nil thread read port.
        override public class var Nil: Self {
            Self(named: mach_port_name_t(THREAD_READ_NULL))
        }
    }

    /// A thread's inspect port.
    public class ThreadInspect: Mach.Thread, Mach.ThreadFlavored {
        /// The ``Mach/ThreadFlavor/inspect`` flavor.
        public let flavor: Mach.ThreadFlavor = .inspect

        /// A nil Thread inspect port.
        override public class var Nil: Self {
            Self(named: mach_port_name_t(THREAD_INSPECT_NULL))
        }
    }
}
