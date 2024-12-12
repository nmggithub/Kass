import Darwin.POSIX
import Foundation
import KassC.LibProc
import KassC.ProcInternal
import KassHelpers

extension BSD {
    public struct ProcSetControlFlavor: KassHelpers.NamedOptionEnum {
        /// The name of the flavor, if it can be determined.
        public var name: String?

        /// Represents a flavor with an optional name.
        public init(name: String?, rawValue: Int32) {
            self.name = name
            self.rawValue = rawValue
        }

        /// The raw value of the flavor.
        public let rawValue: Int32

        /// All known flavors.
        public static let allCases: [Self] = [
            .processorControl, .threadName, .virtualMemoryResourceOwner, .delayIdleSleep,
        ]

        public static let processorControl = Self(
            name: "processorControl", rawValue: PROC_SELFSET_PCONTROL
        )

        public static let threadName = Self(
            name: "threadName", rawValue: PROC_SELFSET_THREADNAME
        )

        public static let virtualMemoryResourceOwner = Self(
            name: "lowResourceVMControlOwnership", rawValue: PROC_SELFSET_VMRSRCOWNER
        )

        public static let delayIdleSleep = Self(
            name: "delayIdleSleep", rawValue: PROC_SELFSET_DELAYIDLESLEEP
        )
    }

    public struct ProcControlState: KassHelpers.NamedOptionEnum {
        /// The name of the state, if it can be determined.
        public var name: String?

        /// Represents a state with an optional name.
        public init(name: String?, rawValue: Int32) {
            self.name = name
            self.rawValue = rawValue
        }

        /// The raw value of the state.
        public let rawValue: Int32

        /// All known states.
        public static let allCases: [Self] = []

        public static let throttle = Self(
            name: "throttle", rawValue: P_PCTHROTTLE
        )

        public static let suspend = Self(
            name: "suspend", rawValue: P_PCSUSP
        )

        public static let kill = Self(
            name: "kill", rawValue: P_PCKILL
        )
    }
}

extension BSD {
    public static func procCallSetControl(
        flavor: BSD.ProcSetControlFlavor,
        // This is set to 0 for calls that don't use it.
        arg: UInt64 = 0,
        buffer: inout Data
    ) throws {
        try Self.procInfo(
            // This flavor will only ever work for the current process, so
            // we might as well just hardcode it with `getpid()`.
            forPID: getpid(),
            call: .setControl,
            flavor: flavor.rawValue,
            arg: arg,
            buffer: &buffer
        )
    }

    public func setSelfControlState(_ state: BSD.ProcControlState) throws {
        var empty = Data()
        try Self.procCallSetControl(
            flavor: .processorControl, arg: UInt64(state.rawValue),
            buffer: &empty
        )
    }

    public static func setSelfThreadName(_ name: String) throws {
        guard var nameData = name.data(using: .utf8) else {
            throw POSIXError(.EINVAL)
        }
        try Self.procCallSetControl(
            flavor: .threadName,
            buffer: &nameData
        )
    }

    public static func setSelfAsVirtualMemoryResourceOwner() throws {
        var empty = Data()
        try Self.procCallSetControl(
            flavor: .virtualMemoryResourceOwner,
            buffer: &empty
        )
    }

    public static func selfSetDelayIdleSleep(_ state: Bool) throws {
        var empty = Data()
        try Self.procCallSetControl(
            flavor: .delayIdleSleep,
            arg: state ? 1 : 0,
            buffer: &empty
        )
    }
}
