import Darwin.POSIX
import Foundation
import KassC.LibProc
import KassHelpers

extension BSD {
    /// A `proc_info` call.
    public struct ProcInfoCall: KassHelpers.NamedOptionEnum {
        /// The name of the call, if it can be determined.
        public var name: String?

        /// Represents a `proc_info` call with an optional name.
        public init(name: String?, rawValue: Int32) {
            self.name = name
            self.rawValue = rawValue
        }

        /// The raw value of the call.
        public let rawValue: Int32

        /// All known `proc_info` calls.
        public static let allCases: [Self] = [
            .listPIDs, .pidInfo, .pidFDInfo, .getKernelMessageBuffer, .setControl, .pidFileportInfo,
            .terminate, .dirtyControl, .pidResourceUsage, .pidOriginatorInfo, .listCoalitions,
            .canUseForegroundHardware, .pidDynamicKQueueInfo, .userDataInfo, .setDyldImages,
            .terminateRSR, .signalAuditToken, .terminateAuditToken, .delegateSignal,
            .delegateTerminate,
        ]

        public static let listPIDs = Self(
            name: "listPIDs", rawValue: PROC_INFO_CALL_LISTPIDS
        )

        public static let pidInfo = Self(
            name: "pidInfo", rawValue: PROC_INFO_CALL_PIDINFO
        )

        public static let pidFDInfo = Self(
            name: "pidFDInfo", rawValue: PROC_INFO_CALL_PIDFDINFO
        )

        public static let getKernelMessageBuffer = Self(
            name: "getKernelMessageBuffer", rawValue: PROC_INFO_CALL_KERNMSGBUF
        )

        public static let setControl = Self(
            name: "setControl", rawValue: PROC_INFO_CALL_SETCONTROL
        )

        public static let pidFileportInfo = Self(
            name: "pidFileportInfo", rawValue: PROC_INFO_CALL_PIDFILEPORTINFO
        )

        public static let terminate = Self(
            name: "terminate", rawValue: PROC_INFO_CALL_TERMINATE
        )

        public static let dirtyControl = Self(
            name: "dirtyControl", rawValue: PROC_INFO_CALL_DIRTYCONTROL
        )

        public static let pidResourceUsage = Self(
            name: "pidResourceUsage", rawValue: PROC_INFO_CALL_PIDRUSAGE
        )

        public static let pidOriginatorInfo = Self(
            name: "orginatorInfo", rawValue: PROC_INFO_CALL_PIDORIGINATORINFO
        )

        public static let listCoalitions = Self(
            name: "listCoalitions", rawValue: PROC_INFO_CALL_LISTCOALITIONS
        )

        public static let canUseForegroundHardware = Self(
            name: "canUseForegroundHardware", rawValue: PROC_INFO_CALL_CANUSEFGHW
        )

        public static let pidDynamicKQueueInfo = Self(
            name: "pidDynamicQueueInfo", rawValue: PROC_INFO_CALL_PIDDYNKQUEUEINFO
        )

        public static let userDataInfo = Self(
            name: "udataInfo", rawValue: PROC_INFO_CALL_UDATA_INFO
        )

        public static let setDyldImages = Self(
            name: "setDyldImages", rawValue: PROC_INFO_CALL_SET_DYLD_IMAGES
        )

        public static let terminateRSR = Self(
            name: "terminateRSR", rawValue: PROC_INFO_CALL_TERMINATE_RSR
        )

        public static let signalAuditToken = Self(
            name: "signalAuditToken", rawValue: PROC_INFO_CALL_SIGNAL_AUDITTOKEN
        )

        public static let terminateAuditToken = Self(
            name: "terminateAuditToken", rawValue: PROC_INFO_CALL_TERMINATE_AUDITTOKEN
        )

        public static let delegateSignal = Self(
            name: "delegateSignal", rawValue: PROC_INFO_CALL_DELEGATE_SIGNAL
        )

        public static let delegateTerminate = Self(
            name: "delegateTerminate", rawValue: PROC_INFO_CALL_DELEGATE_TERMINATE
        )
    }

    /// A proc_info_extended_id` flag.
    struct ProcInfoExtendedIDFlag: KassHelpers.NamedOptionEnum {
        /// The name of the flag, if it can be determined.
        public var name: String?

        /// Represents a `proc_info_extended_id` flag with an optional name.
        public init(name: String?, rawValue: UInt32) {
            self.name = name
            self.rawValue = rawValue
        }

        /// The raw value of the flag.
        public let rawValue: UInt32

        /// All known `proc_info_extended_id` flags.
        public static let allCases: [Self] = [.compareIDVersion, .compareUniqueID]

        public static let compareIDVersion = Self(
            name: "compareIDVersion", rawValue: UInt32(PIF_COMPARE_IDVERSION)
        )

        public static let compareUniqueID = Self(
            name: "compareID", rawValue: UInt32(PIF_COMPARE_UNIQUEID)
        )
    }

    /// An extended ID for use with `proc_info_extended_id`.
    public struct ProcInfoExtendedID {
        /// The flag for the extended ID.
        let flag: ProcInfoExtendedIDFlag

        /// The extended ID.
        let value: UInt64
    }
}

extension BSD.Proc {
    /// Calls the `proc_info` syscall.
    @discardableResult
    public static func info(
        forPID pid: pid_t = 0,
        call: BSD.ProcInfoCall,
        // The semantics of these two are different for each call. They are set to
        // 0 by default to indicate "no value" for calls that don't use them.
        flavor: Int32 = 0,
        arg: UInt64 = 0,
        buffer: inout Data,
        // This is set to `nil` by default to use the non-extended syscall.
        extendedID: BSD.ProcInfoExtendedID? = nil
    ) throws -> Int32 {
        return try buffer.withUnsafeMutableBytes {
            (bufferPointer) -> Int32 in
            if let actualExtendedID = extendedID {
                try BSD.call(
                    __proc_info_extended_id(
                        call.rawValue, pid, UInt32(flavor),
                        actualExtendedID.flag.rawValue, actualExtendedID.value,
                        arg,
                        UInt64(UInt(bitPattern: bufferPointer.baseAddress)),
                        Int32(bufferPointer.count)
                    )
                )
            } else {
                try BSD.call(
                    __proc_info(
                        call.rawValue, pid, flavor, arg,
                        bufferPointer.baseAddress, Int32(bufferPointer.count)
                    )
                )
            }
        }
    }

    /// Gets the kernel message buffer.
    /// - Note: This must be called with root privileges.
    public static func getKernelMessageBuffer(largeBuffer: Bool = true) throws -> Data {
        // These are defined at build time in the XNU kernel source code. It seems that the
        // macOS builds use the larger size, while other builds use the smaller one. Though
        // this library is primarily meant for macOS, we should provide the smaller size as
        // an option (especially if we ever want to support other platforms).
        let bufferSize = largeBuffer ? 131072 : 16384
        var buffer = Data(count: bufferSize)
        let returnedSize = try BSD.Proc.info(call: .getKernelMessageBuffer, buffer: &buffer)
        return buffer.prefix(Int(returnedSize))
    }
}
