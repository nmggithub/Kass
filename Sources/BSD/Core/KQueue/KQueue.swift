import Darwin
import Foundation
import KassC.EventPrivate
import KassHelpers

extension BSD {
    /// A filter type for a kevent.
    public struct KEventFilterType: KassHelpers.NamedOptionEnum {
        /// The name of the filter type, if it can be determined.
        public var name: String?

        /// The raw value of the filter type.
        public let rawValue: Int16

        /// Initializes a filter type with the given name and raw value.
        public init(name: String?, rawValue: Int16) {
            self.name = name
            self.rawValue = rawValue
        }

        /// All known filter types.
        public static let allCases: [Self] = [
            .read,
            .write,
            .aio,
            .vnode,
            .proc,
            .signal,
            .machPort,
            .timer,
            .fileSystem,
            .user,
            .virtualMemory,
            .exception,
        ]

        public static let read = Self(name: "read", rawValue: Int16(EVFILT_READ))
        public static let write = Self(name: "write", rawValue: Int16(EVFILT_WRITE))
        public static let aio = Self(name: "aio", rawValue: Int16(EVFILT_AIO))
        public static let vnode = Self(name: "vnode", rawValue: Int16(EVFILT_VNODE))
        public static let proc = Self(name: "proc", rawValue: Int16(EVFILT_PROC))
        public static let signal = Self(name: "signal", rawValue: Int16(EVFILT_SIGNAL))
        public static let timer = Self(name: "timer", rawValue: Int16(EVFILT_TIMER))
        public static let machPort = Self(name: "machPort", rawValue: Int16(EVFILT_MACHPORT))
        public static let fileSystem = Self(name: "fileSystem", rawValue: Int16(EVFILT_FS))
        public static let user = Self(name: "user", rawValue: Int16(EVFILT_USER))
        public static let virtualMemory = Self(name: "virtualMemory", rawValue: Int16(EVFILT_VM))
        public static let exception = Self(name: "exception", rawValue: Int16(EVFILT_EXCEPT))

        // Private filter types

        public static let unused11 = Self(
            name: "unused11", rawValue: Int16(EVFILT_UNUSED_11)
        )
        public static let socket = Self(
            name: "socket", rawValue: Int16(EVFILT_SOCK)
        )
        public static let memorystatus = Self(
            name: "memorystatus", rawValue: Int16(EVFILT_MEMORYSTATUS)
        )
        public static let skywalkChannel = Self(
            name: "skywalkChannel", rawValue: Int16(EVFILT_NW_CHANNEL)
        )
        public static let workloop = Self(
            name: "workloop", rawValue: Int16(EVFILT_WORKLOOP)
        )
        public static let exclavesNotification = Self(
            name: "exclaves", rawValue: Int16(EVFILT_EXCLAVES_NOTIFICATION)
        )
    }

    /// Flags for a kevent.
    public struct KEventFlags: OptionSet, KassHelpers.NamedOptionEnum {
        /// The name of the flag, if it can be determined.
        public var name: String?

        /// The raw value of the flag.
        public let rawValue: UInt16

        /// Initializes a kevent flag with the given name and raw value.
        public init(name: String?, rawValue: UInt16) {
            self.name = name
            self.rawValue = rawValue
        }

        /// The individual flags in the collection.
        public var flags: [Self] { Self.allCases.filter { self.contains($0) } }

        /// All known kevent flags.
        public static let allCases: [Self] = [
            .add,
            .delete,
            .enable,
            .disable,
            .oneshot,
            .clear,
            .receipt,
            .dispatch,
            .userDataSpecific,
            .disaptch2,
            .vanished,
        ]

        // Actions
        public static let add = Self(name: "add", rawValue: UInt16(EV_ADD))
        public static let delete = Self(name: "delete", rawValue: UInt16(EV_DELETE))
        public static let enable = Self(name: "enable", rawValue: UInt16(EV_ENABLE))
        public static let disable = Self(name: "disable", rawValue: UInt16(EV_DISABLE))

        // Other flags
        public static let oneshot = Self(name: "oneshot", rawValue: UInt16(EV_ONESHOT))
        public static let clear = Self(name: "clear", rawValue: UInt16(EV_CLEAR))
        public static let receipt = Self(name: "receipt", rawValue: UInt16(EV_RECEIPT))
        public static let dispatch = Self(name: "dispatch", rawValue: UInt16(EV_DISPATCH))
        public static let userDataSpecific = Self(
            name: "userDataSpecific", rawValue: UInt16(EV_UDATA_SPECIFIC)
        )
        public static let disaptch2 = Self(name: "dispatch2", rawValue: UInt16(EV_DISPATCH2))
        public static let vanished = Self(name: "vanished", rawValue: UInt16(EV_VANISHED))
    }

    /// A returned value for a kevent.
    public struct KEventReturnedValues: KassHelpers.NamedOptionEnum {
        public var name: String?
        public let rawValue: Int32

        public init(name: String?, rawValue: Int32) {
            self.name = name
            self.rawValue = rawValue
        }

        public static let allCases: [Self] = [
            .error,
            .eof,
        ]

        public static let error = Self(name: "error", rawValue: EV_ERROR)
        public static let eof = Self(name: "eof", rawValue: EV_EOF)

    }
}

extension kevent {
    /// Initializes a kevent with the given parameters.
    public init(
        identifier: UInt,
        filter: BSD.KEventFilterType,
        flags: BSD.KEventFlags,
        filterFlags: UInt32 = 0,
        filterData: Int = 0,
        userData: UnsafeMutableRawPointer? = nil
    ) {
        self.init(
            ident: identifier,
            filter: filter.rawValue,
            flags: flags.rawValue,
            fflags: filterFlags,
            data: filterData,
            udata: userData
        )
    }
}

extension kevent: @retroactive CustomStringConvertible {
    public var description: String {
        """
        kevent(
            ident: \(ident),
            filter: \(BSD.KEventFilterType(rawValue: filter)),
            flags: \(BSD.KEventFlags(rawValue: flags).flags),
            fflags: \(fflags),
            data: \(data),
            udata: \(String(describing: udata))
        )
        """
    }
}

extension kevent64_s {
    /// Initializes a kevent64_s with the given parameters.
    public init(
        identifier: UInt64,
        filter: BSD.KEventFilterType,
        flags: BSD.KEventFlags,
        filterFlags: UInt32 = 0,
        filterData: Int64 = 0,
        userData: UnsafeMutableRawPointer? = nil,
        extensions: (UInt64, UInt64) = (0, 0)
    ) {
        self.init(
            ident: identifier,
            filter: filter.rawValue,
            flags: flags.rawValue,
            fflags: filterFlags,
            data: filterData,
            udata: UInt64(UInt(bitPattern: userData)),
            ext: extensions
        )
    }
}

extension kevent64_s: @retroactive CustomStringConvertible {
    public var description: String {
        """
        kevent64_s(
            ident: \(ident),
            filter: \(BSD.KEventFilterType(rawValue: filter)),
            flags: \(BSD.KEventFlags(rawValue: flags).flags),
            fflags: \(fflags),
            data: \(data),
            udata: \(String(describing: udata))
        )
        """
    }
}

extension kevent_qos_s {
    /// Initializes a kevent_qos_s with the given parameters.
    public init(
        identifier: UInt64,
        filter: BSD.KEventFilterType,
        flags: BSD.KEventFlags,
        filterFlags: UInt32 = 0,
        extraFilterFlags: UInt32 = 0,
        filterData: Int64 = 0,
        userData: UnsafeMutableRawPointer? = nil,
        qos: Int32 = 0,
        extensions: (UInt64, UInt64, UInt64, UInt64) = (0, 0, 0, 0)
    ) {
        self.init(
            ident: identifier,
            filter: filter.rawValue,
            flags: flags.rawValue,
            qos: qos,
            udata: UInt64(UInt(bitPattern: userData)),
            fflags: filterFlags,
            xflags: extraFilterFlags,
            data: filterData,
            ext: extensions
        )
    }
}

extension kevent_qos_s: @retroactive CustomStringConvertible {
    public var description: String {
        """
        kevent_qos_s(
            ident: \(ident),
            filter: \(BSD.KEventFilterType(rawValue: filter)),
            flags: \(BSD.KEventFlags(rawValue: flags).flags),
            qos: \(qos),
            fflags: \(fflags),
            xflags: \(xflags),
            data: \(data),
            udata: \(String(describing: udata))
        )
        """
    }
}

extension BSD {

    /// A class representing a kqueue.
    public class KQueue: RawRepresentable {

        /// The raw value (file descriptor) of the kqueue.
        public var rawValue: Int32

        /// Initializes a kqueue with the given raw value.
        public required init?(rawValue: Int32) {
            self.rawValue = rawValue
        }

        /// Creates a new kqueue.
        public init() throws {
            self.rawValue = try BSDCore.BSD.call(kqueue())
        }

        /// Registers and/or retrieves events for the kqueue.
        @discardableResult
        public func event(
            registeringEvents changes: [kevent]? = nil,
            retrievingEventsOfCount requestedRetrieveCount: Int32 = 0,
            timeout: timespec? = nil
        ) throws -> [kevent]? {
            var events: [kevent] = .init(
                repeating: Darwin.kevent(), count: Int(requestedRetrieveCount)
            )
            let timeoutPointer: UnsafeMutablePointer<timespec>? =
                timeout != nil
                ? {
                    let pointer = UnsafeMutablePointer<timespec>.allocate(capacity: 1)
                    pointer.initialize(to: timeout!)
                    return pointer
                }() : nil
            defer { timeoutPointer?.deallocate() }
            let actualRetrieveCount = try BSDCore.BSD.call(
                kevent(
                    self.rawValue,
                    changes,
                    Int32(changes?.count ?? 0),
                    &events,
                    Int32(events.count),
                    timeoutPointer
                )
            )
            return actualRetrieveCount > 0 ? Array(events.prefix(Int(actualRetrieveCount))) : nil
        }

        /// Registers and/or retrieves events for the kqueue.
        @discardableResult
        public func event64(
            _ changes: [kevent64_s]? = nil,
            retrievingEventsOfCount requestedRetrieveCount: Int32 = 0,
            flags: UInt32 = 0,
            timeout: timespec? = nil
        ) throws -> [kevent64_s]? {
            var events: [kevent64_s] = .init(
                repeating: kevent64_s(), count: Int(requestedRetrieveCount))
            let timeoutPointer: UnsafeMutablePointer<timespec>? =
                timeout != nil
                ? {
                    let pointer = UnsafeMutablePointer<timespec>.allocate(capacity: 1)
                    pointer.initialize(to: timeout!)
                    return pointer
                }() : nil
            defer { timeoutPointer?.deallocate() }
            let actualRetrieveCount = try BSDCore.BSD.call(
                Darwin.kevent64(
                    self.rawValue,
                    changes,
                    Int32(changes?.count ?? 0),
                    &events,
                    Int32(events.count),
                    flags,
                    timeoutPointer
                )
            )
            return actualRetrieveCount > 0 ? Array(events.prefix(Int(actualRetrieveCount))) : nil
        }

        /// Registers and/or retrieves events for the kqueue.
        @discardableResult
        public func eventQOS(
            _ changes: [kevent_qos_s]? = nil,
            retrievingEventsOfCount requestedRetrieveCount: Int32 = 0,
            flags: UInt32 = 0
        ) throws -> (events: [kevent_qos_s]?, data: Data) {
            var events: [kevent_qos_s] = .init(
                repeating: kevent_qos_s(), count: Int(requestedRetrieveCount))
            var dataOut = Data(capacity: size_t.max)
            let (dataOutSize, actualRetrieveCount) =
                try dataOut.withUnsafeMutableBytes { bytes in
                    var dataSize = size_t(bytes.count)
                    let actualRetrieveCount = try BSDCore.BSD.call(
                        KassC.kevent_qos(
                            self.rawValue,
                            changes,
                            Int32(changes?.count ?? 0),
                            &events,
                            Int32(events.count),
                            bytes.baseAddress,
                            &dataSize,
                            flags
                        )
                    )
                    return (dataSize, actualRetrieveCount)
                }
            return (
                events: actualRetrieveCount > 0
                    ? Array(events.prefix(Int(actualRetrieveCount))) : nil,
                data: dataOut.prefix(dataOutSize)
            )
        }

        /// Registers and/or retrieves events for the kqueue with a given ID.
        @discardableResult
        public static func eventID(
            _ changes: [kevent_qos_s]? = nil,
            forKQueueWithID id: kqueue_id_t,
            retrievingEventsOfCount retrieveCount: Int32 = 0,
            flags: UInt32 = 0
        ) throws -> (events: [kevent_qos_s]?, data: Data) {
            var events: [kevent_qos_s] = .init(repeating: kevent_qos_s(), count: Int(retrieveCount))
            var dataOut = Data(capacity: size_t.max)
            let (dataOutSize, actualRetrieveCount) =
                try dataOut.withUnsafeMutableBytes { bytes in
                    var dataSize = size_t(bytes.count)
                    let actualRetrieveCount = try BSDCore.BSD.call(
                        KassC.kevent_id(
                            id,
                            changes,
                            Int32(changes?.count ?? 0),
                            &events,
                            Int32(events.count),
                            bytes.baseAddress,
                            &dataSize,
                            flags
                        )
                    )
                    return (dataSize, actualRetrieveCount)
                }
            return (
                events: actualRetrieveCount > 0
                    ? Array(events.prefix(Int(actualRetrieveCount))) : nil,
                data: dataOut.prefix(dataOutSize)
            )
        }

        deinit { close(self.rawValue) }
    }
}
