import Darwin.POSIX
import Foundation
import KassC.ProcInfo
import KassC.ProcInfoPrivate
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
            .listPIDs,
            .pidInfo,
            .pidFDInfo,
            .kernelMessageBuffer,
            .setControl,
            .pidFileportInfo,
            .terminate,
            .dirtyControl,
            .pidResourceUsage,
            .pidOriginatorInfo,
            .listCoalitions,
            .canUseForegroundHardware,
            .pidDynamicKernelQueueInfo,
            .userDataInfo,
            .setDyldImages,
            .terminateRSR,
            .signalAuditToken,
            .terminateAuditToken,
            .delegateSignal,
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

        public static let kernelMessageBuffer = Self(
            name: "kernelMessageBuffer", rawValue: PROC_INFO_CALL_KERNMSGBUF
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

        public static let pidDynamicKernelQueueInfo = Self(
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

    // An extended ID for use with `proc_info_extended_id`.
    public struct ProcInfoExtendedID {
        /// The flag for the extended ID.
        let flag: ProcInfoExtendedIDFlag

        /// The extended ID.
        let value: UInt64
    }

    /// Helper functions for working with processes.
    public struct Proc {
        public func info(
            _ pid: pid_t,
            call: ProcInfoCall,
            // The semantics of these two are different for each call. They are set to
            // 0 by default to indicate "no value" for calls that don't use them.
            flavor: Int32 = 0,
            arg: UInt64 = 0,
            // This is set to an empty buffer by default for calls that don't use it.
            buffer: inout Data,
            // This is set to nil to `nil` by default to use the non-extended syscall.
            extendedID: ProcInfoExtendedID? = nil
        ) throws {
            try buffer.withUnsafeMutableBytes {
                (bufferPointer) -> Void in
                if let actualExtendedID = extendedID {
                    __proc_info_extended_id(
                        call.rawValue, pid, UInt32(flavor),
                        actualExtendedID.flag.rawValue, actualExtendedID.value,
                        arg,
                        UInt64(UInt(bitPattern: bufferPointer.baseAddress)),
                        Int32(bufferPointer.count)
                    )
                } else {
                    try BSD.syscall(
                        __proc_info(
                            call.rawValue, pid, flavor, arg,
                            bufferPointer.baseAddress, Int32(bufferPointer.count)
                        )
                    )
                }
            }
        }
    }
}
