import Darwin.Mach
import KassC.MachEventlink
import KassHelpers

extension Mach {
    public class Eventlink: Mach.Port {
        /// Creates a new eventlink port pair.
        public static func create(
            // The kernel currently won't accept any task other than the current one, so we'll default to
            // that while keeping the parameter for completeness (as the call still takes in a task).
            task: Mach.Task = Mach.Task.current,
            // Currently, it seems that `.noCopyIn` is the only option the kernel will accept, but the
            // others are still included in the header. We'll include them for completeness below, but
            // we'll default to `.noCopyIn` so the default behavior of this function actually works.
            option: mach_eventlink_create_option_t = .noCopyIn
        ) throws -> (Eventlink, Eventlink) {
            var portPair = [mach_port_t(MACH_PORT_NULL), mach_port_t(MACH_PORT_NULL)]
            try Mach.call(mach_eventlink_create(task.name, option, &portPair))
            return (Eventlink(named: portPair[0]), Eventlink(named: portPair[1]))
        }

        /// Associates a thread with an eventlink port.
        /// - Note: The addresses and masks are currently unused by the kernel, but the parameters are
        /// included for completeness.
        public func associate(
            thread: Mach.Thread,
            waitAddress: UnsafeRawPointer? = nil,
            waitMask: UInt64 = 0,
            signalAddress: UnsafeRawPointer? = nil,
            signalMask: UInt64 = 0,
            option: mach_eventlink_associate_option_t
        ) throws {
            try Mach.call(
                mach_eventlink_associate(
                    self.name,
                    thread.name,
                    UInt64(UInt(bitPattern: waitAddress)),
                    waitMask,
                    UInt64(UInt(bitPattern: signalAddress)),
                    signalMask,
                    option
                ))
        }

        /// Disassociates a thread from an eventlink port.
        public func disassociate(option: mach_eventlink_disassociate_option_t = .none) throws {
            try Mach.call(mach_eventlink_disassociate(self.name, option))
        }

        /// Destroys the eventlink port.
        public override func destroy() throws {
            try Mach.call(mach_eventlink_destroy(self.name))
        }
    }
}

extension mach_eventlink_create_option_t {
    public static let none: mach_eventlink_create_option_t = []
    public static let noCopyIn = mach_eventlink_create_option_t.MELC_OPTION_NO_COPYIN
    public static let withCopyIn = mach_eventlink_create_option_t.MELC_OPTION_WITH_COPYIN
}

extension mach_eventlink_associate_option_t {
    public static let none: mach_eventlink_associate_option_t = []
    public static let associateOnWait =
        mach_eventlink_associate_option_t.MELA_OPTION_ASSOCIATE_ON_WAIT
}

extension mach_eventlink_disassociate_option_t {
    public static let none: mach_eventlink_disassociate_option_t = []
}
