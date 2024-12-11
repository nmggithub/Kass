import Darwin.Mach.exception_types
import KassC.ExceptionPrivate
import KassHelpers

extension Mach {
    /// A type of exception.
    public struct ExceptionType: KassHelpers.NamedOptionEnum {
        /// The name of the exception type, if it can be determined.
        public let name: String?

        /// Represents an exception type with an optional name.
        public init(name: String?, rawValue: exception_type_t) {
            self.name = name
            self.rawValue = rawValue
        }

        /// The raw value of the exception type.
        public let rawValue: exception_type_t

        /// All known exception types.
        public static let allCases: [Self] = [
            .badAccess, .badInstruction, .arithmetic, .emulation, .software, .breakpoint,
            .syscall, .machSyscall, .rpcAlert, .crash, .resource, .guard, .corpseNotify,
        ]

        public static let badAccess = Self(name: "badAccess", rawValue: EXC_BAD_ACCESS)

        public static let badInstruction = Self(
            name: "badInstruction", rawValue: EXC_BAD_INSTRUCTION
        )

        public static let arithmetic = Self(name: "arithmetic", rawValue: EXC_ARITHMETIC)

        public static let emulation = Self(name: "emulation", rawValue: EXC_EMULATION)

        public static let software = Self(name: "software", rawValue: EXC_SOFTWARE)

        public static let breakpoint = Self(name: "breakpoint", rawValue: EXC_BREAKPOINT)

        public static let syscall = Self(name: "syscall", rawValue: EXC_SYSCALL)

        public static let machSyscall = Self(name: "machSyscall", rawValue: EXC_MACH_SYSCALL)

        public static let rpcAlert = Self(name: "rpcAlert", rawValue: EXC_RPC_ALERT)

        public static let crash = Self(name: "crash", rawValue: EXC_CRASH)

        public static let resource = Self(name: "resource", rawValue: EXC_RESOURCE)

        public static let `guard` = Self(name: "guard", rawValue: EXC_GUARD)

        public static let corpseNotify = Self(name: "corpseNotify", rawValue: EXC_CORPSE_NOTIFY)
    }

    /// A behavior for an exception.
    public struct ExceptionBehavior: KassHelpers.NamedOptionEnum {
        /// The name of the exception behavior, if it can be determined.
        public let name: String?

        /// The actual raw value of the exception behavior (with flags).
        private let rawValueWithFlags: UInt32

        /// Extracts the raw value of the exception behavior (without flags).
        private static func behaviorValueWithoutFlags(_ value: exception_behavior_t)
            -> exception_behavior_t
        {
            // The `MACH_EXCEPTION_MASK` macro is not available in Swift, so we need to define it manually here.
            let MACH_EXCEPTION_MASK: UInt32 =
                MACH_EXCEPTION_CODES
                | UInt32(MACH_EXCEPTION_ERRORS)
                | UInt32(MACH_EXCEPTION_BACKTRACE_PREFERRED)
            return exception_behavior_t(
                // `exception_behavior_t` is an `Int32` for some reason, so we need
                //  to convert it to a `UInt32` to apply mask out the flags.
                UInt32(bitPattern: value) & ~MACH_EXCEPTION_MASK
            )
        }

        /// Represents an exception behavior with an optional name.
        public init(name: String?, rawValue: exception_behavior_t) {
            self.name = name
            self.rawValue = Self.behaviorValueWithoutFlags(rawValue)
            self.rawValueWithFlags = UInt32(bitPattern: rawValue)
        }

        /// Represents an option with a raw value, taking one of the known cases if the raw value matches one.
        public init(rawValue: RawValue) {
            guard
                let value = Self.allCases.first(
                    where: { $0.rawValue == Self.behaviorValueWithoutFlags(rawValue) }
                )
            else {
                self.init(name: nil, rawValue: rawValue)
                return
            }
            self = value
        }

        /// The raw value of the exception behavior.
        public let rawValue: exception_behavior_t

        public var backtracePreferred: Bool {
            self.rawValueWithFlags & UInt32(MACH_EXCEPTION_BACKTRACE_PREFERRED) != 0
        }

        public var additionalErrors: Bool {
            self.rawValueWithFlags & UInt32(MACH_EXCEPTION_ERRORS) != 0
        }

        public var codes: Bool {
            self.rawValueWithFlags & MACH_EXCEPTION_CODES != 0
        }

        /// All known exception behaviors.
        public static let allCases: [Self] = [
            .default, .state, .stateIdentity, .identityProtected, .stateIdentityProtected,
        ]

        public static let `default` = Self(name: "default", rawValue: EXCEPTION_DEFAULT)

        public static let state = Self(name: "state", rawValue: EXCEPTION_STATE)

        public static let stateIdentity = Self(
            name: "stateIdentity", rawValue: EXCEPTION_STATE_IDENTITY
        )

        public static let identityProtected = Self(
            name: "identityProtected", rawValue: EXCEPTION_IDENTITY_PROTECTED
        )

        public static let stateIdentityProtected = Self(
            name: "stateIdentityProtected", rawValue: EXCEPTION_STATE_IDENTITY_PROTECTED
        )
    }

    /// A mask for getting or setting exception ports.
    public struct ExceptionMask: KassHelpers.NamedOptionEnum, OptionSet {
        /// The name of the exception mask, if it can be determined.
        public let name: String?

        /// Represents an exception mask with an optional name.
        public init(name: String?, rawValue: UInt32) {
            self.name = name
            self.rawValue = rawValue
        }

        /// The raw value of the exception mask.
        public let rawValue: UInt32

        /// All known exception masks.
        public static let allCases: [Self] = [
            .badAccess, .badInstruction, .arithmetic, .emulation, .software, .breakpoint,
            .syscall, .machSyscall, .rpcAlert, .crash, .resource, .guard, .corpseNotify,
        ]

        public static var all: Self {
            var literalAll: Self = []  // We take advantage of the fact that `OptionSet` is `ExpressibleByArrayLiteral`.
            for exception in allCases { literalAll.insert(exception) }
            return Self(name: "all", rawValue: literalAll.rawValue)
        }

        /// The individual masks that are contained in the mask.
        public var masks: [Self] { Self.allCases.filter { self.contains($0) } }

        public static let badAccess = Self(name: "badAccess", rawValue: UInt32(EXC_MASK_BAD_ACCESS))

        public static let badInstruction = Self(
            name: "badInstruction", rawValue: UInt32(EXC_MASK_BAD_INSTRUCTION)
        )

        public static let arithmetic = Self(
            name: "arithmetic", rawValue: UInt32(EXC_MASK_ARITHMETIC))

        public static let emulation = Self(name: "emulation", rawValue: UInt32(EXC_MASK_EMULATION))

        public static let software = Self(name: "software", rawValue: UInt32(EXC_MASK_SOFTWARE))

        public static let breakpoint = Self(
            name: "breakpoint", rawValue: UInt32(EXC_MASK_BREAKPOINT))

        public static let syscall = Self(name: "syscall", rawValue: UInt32(EXC_MASK_SYSCALL))

        public static let machSyscall = Self(
            name: "machSyscall", rawValue: UInt32(EXC_MASK_MACH_SYSCALL)
        )

        public static let rpcAlert = Self(name: "rpcAlert", rawValue: UInt32(EXC_MASK_RPC_ALERT))

        public static let crash = Self(name: "crash", rawValue: UInt32(EXC_MASK_CRASH))

        public static let resource = Self(name: "resource", rawValue: UInt32(EXC_MASK_RESOURCE))

        public static let `guard` = Self(name: "guard", rawValue: UInt32(EXC_MASK_GUARD))

        public static let corpseNotify = Self(
            name: "corpseNotify", rawValue: UInt32(EXC_MASK_CORPSE_NOTIFY)
        )
    }

    /// An exception port.
    public class ExceptionPort: Mach.Port {
        /// The mask of the exception types that the port will catch.
        public let mask: Mach.ExceptionMask

        /// The behavior of the exception.
        public let behavior: Mach.ExceptionBehavior

        /// The flavor of the thread state to send with exception messages.
        public let threadStateFlavor: Mach.ThreadStateFlavor

        /// Creates an exception port.
        public init(
            named name: mach_port_name_t,
            mask: Mach.ExceptionMask = .all,
            behavior: Mach.ExceptionBehavior = .default,
            threadStateFlavor: Mach.ThreadStateFlavor = .none
        ) {
            self.mask = mask
            self.behavior = behavior
            self.threadStateFlavor = threadStateFlavor
            super.init(named: name)
        }

        @available(*, unavailable, message: "Use init(named:behavior:) instead.")
        public required init(named name: mach_port_name_t, inNameSpaceOf task: Task = .current) {
            self.mask = .all
            self.behavior = .default
            self.threadStateFlavor = .none
            super.init(named: name)
        }

        /// Raise an exception.
        /// - Important: The `wasMaybePACFail` parameter has no effect on non-ARM platforms.
        public func raise(
            _ type: Mach.ExceptionType,
            code: Int32,
            subcode: Int32,
            inThread thread: Mach.Thread = Mach.Thread.current,
            inTask task: Mach.Task = Mach.Task.current,
            wasMaybePACFail: Bool = false
        ) throws {
            var typeValue = type.rawValue
            #if arch(arm) || arch(arm64)
                typeValue |= (wasMaybePACFail ? EXC_PTRAUTH_BIT : 0)
            #endif
            var codeWithSubcode = [code, subcode]
            switch self.behavior {
            case .default:
                try Mach.call(
                    exception_raise(
                        self.name, thread.name, task.name, typeValue, &codeWithSubcode,
                        UInt32(codeWithSubcode.count)
                    )
                )
                break
            case .state:
                var flavor = self.threadStateFlavor.rawValue
                var oldStateCount = mach_msg_type_number_t(THREAD_STATE_MAX)
                let oldState = thread_state_t.allocate(capacity: Int(oldStateCount))
                try Mach.call(thread_get_state(thread.name, flavor, oldState, &oldStateCount))
                var newStateCount = mach_msg_type_number_t(THREAD_STATE_MAX)
                let newState = thread_state_t.allocate(capacity: Int(newStateCount))
                try Mach.call(
                    exception_raise_state(
                        self.name, typeValue, &codeWithSubcode,
                        UInt32(codeWithSubcode.count), &flavor,
                        oldState, oldStateCount, newState, &newStateCount
                    )
                )
                try Mach.call(thread_set_state(thread.name, flavor, newState, newStateCount))
                break
            case .stateIdentity:
                var flavor = self.threadStateFlavor.rawValue
                var oldStateCount = mach_msg_type_number_t(THREAD_STATE_MAX)
                let oldState = thread_state_t.allocate(capacity: Int(oldStateCount))
                try Mach.call(thread_get_state(thread.name, flavor, oldState, &oldStateCount))
                var newStateCount = mach_msg_type_number_t(THREAD_STATE_MAX)
                let newState = thread_state_t.allocate(capacity: Int(newStateCount))
                try Mach.call(
                    exception_raise_state_identity(
                        self.name, thread.name, task.name, typeValue, &codeWithSubcode,
                        UInt32(codeWithSubcode.count), &flavor,
                        oldState, oldStateCount, newState, &newStateCount
                    )
                )
                try Mach.call(thread_set_state(thread.name, flavor, newState, newStateCount))
                break
            default: break  // The other cases are currently unsupported.
            }
        }
    }
}
