import Darwin.POSIX
import Foundation
import KassC.SpawnPrivate  // For private flags
import KassHelpers
import MachCore
import System

extension BSD {
    // MARK: - POSIXSpawnFlags

    /// Flags for a POSIX spawn call.
    public struct POSIXSpawnFlags: OptionSet, KassHelpers.NamedOptionEnum {
        /// The name of the flag, if it can be determined.
        public var name: String?

        /// Represents a POSIX spawn flag with an optional name.
        public init(name: String?, rawValue: Int16) {
            self.name = name
            self.rawValue = rawValue
        }

        /// The raw value of the flag.
        public let rawValue: Int16

        /// The individual flags in the collection.
        public var flags: [Self] { self.values }

        /// All known POSIX spawn flags.
        public static let allCases: [Self] = [
            .resetIDs,
            .setProcessGroup,
            .setDefaultSignalSet,
            .setSignalMask,
            .setExec,
            .startSuspended,
            .disableASLR,
            .nanoAllocator,
            .setSID,
            .disallowDataExecution,
            .closeParentFileDescriptors,
            .reslideSharedRegion,
        ]

        public static let resetIDs = Self(
            name: "resetIDs", rawValue: Int16(POSIX_SPAWN_RESETIDS)
        )

        public static let setProcessGroup = Self(
            name: "setProcessGroup", rawValue: Int16(POSIX_SPAWN_SETPGROUP)
        )

        public static let setDefaultSignalSet = Self(
            name: "setDefaultSignalSet", rawValue: Int16(POSIX_SPAWN_SETSIGDEF)
        )

        public static let setSignalMask = Self(
            name: "setSignalMask", rawValue: Int16(POSIX_SPAWN_SETSIGMASK)
        )

        public static let setExec = Self(
            name: "setExec", rawValue: Int16(POSIX_SPAWN_SETEXEC)
        )

        public static let startSuspended = Self(
            name: "startSuspended", rawValue: Int16(POSIX_SPAWN_START_SUSPENDED)
        )

        public static let disableASLR = Self(
            name: "disableASLR", rawValue: Int16(_POSIX_SPAWN_DISABLE_ASLR)
        )

        public static let nanoAllocator = Self(
            name: "nanoAllocator", rawValue: Int16(_POSIX_SPAWN_NANO_ALLOCATOR)
        )

        public static let setSID = Self(
            name: "setSID", rawValue: Int16(POSIX_SPAWN_SETSID)
        )

        public static let disallowDataExecution = Self(
            // Yes, this flag is named weirdly, but the kernel source code comments it as
            //  a flag that *disables* execution from pages, despite its name.
            name: "disallowDataExecution", rawValue: Int16(_POSIX_SPAWN_ALLOW_DATA_EXEC)
        )

        public static let closeParentFileDescriptors = Self(
            name: "closeParentFileDescriptors", rawValue: Int16(POSIX_SPAWN_CLOEXEC_DEFAULT)
        )

        public static let reslideSharedRegion = Self(
            name: "reslideSharedRegion", rawValue: Int16(_POSIX_SPAWN_RESLIDE)
        )
    }

    // MARK: - POSIXSpawnCPUSecurityMitigations

    /// CPU security mitigations for a POSIX spawn call.
    public struct POSIXSpawnCPUSecurityMitigations: OptionSet, KassHelpers.NamedOptionEnum {
        /// The name of the flag, if it can be determined.
        public var name: String?

        /// Represents a CPU security mitigation flag with an optional name.
        public init(name: String?, rawValue: UInt32) {
            self.name = name
            self.rawValue = rawValue
        }

        /// The raw value of the flag.
        public let rawValue: UInt32

        /// The individual flags in the collection.
        public var flags: [Self] { self.values }

        /// All known CPU security mitigation flags.
        public static let allCases: [Self] = [
            .all,
            .noSimultaneousMultiThreading,
            .threadsMustEnableCPUSecurity,
        ]

        public static let all = Self(
            name: "all", rawValue: UInt32(POSIX_SPAWN_NP_CSM_ALL)
        )

        public static let noSimultaneousMultiThreading = Self(
            name: "noSimultaneousMultiThreading", rawValue: UInt32(POSIX_SPAWN_NP_CSM_NOSMT)
        )

        public static let threadsMustEnableCPUSecurity = Self(
            name: "threadsMustEnableCPUSecurity", rawValue: UInt32(POSIX_SPAWN_NP_CSM_TECS)
        )
    }

    // MARK: - POSIXSpawnAttributes

    /// Attributes for a POSIX spawn call.
    public final class POSIXSpawnAttributes: RawRepresentable {
        /// The raw attributes.
        public var rawValue: UnsafeMutablePointer<posix_spawnattr_t?>

        /// Calls a function with a pointer to the raw value and throws an error if it fails.
        /// - Note: This is meant for `posix_spawnattr_t_*` functions that take a pointer to the raw value.
        package func call(_ call: (UnsafeMutablePointer<posix_spawnattr_t?>) -> Int32) throws {
            try BSDCore.BSD.call(call(self.rawValue))
        }

        /// Initializes a new POSIX spawn attributes object with the given raw value.
        public init(rawValue: UnsafeMutablePointer<posix_spawnattr_t?>) {
            self.rawValue = rawValue
        }

        /// Initializes a new POSIX spawn attributes object.
        public convenience init() throws {
            let attrPointer = UnsafeMutablePointer<posix_spawnattr_t?>.allocate(capacity: 1)
            try BSDCore.BSD.call(posix_spawnattr_init(attrPointer))
            guard attrPointer.pointee != nil else {
                // If we somehow got past the return code check above, but the raw value is
                //  still nil, we have a problem. We simulate a kernel memory error.
                throw POSIXError(.ENOMEM)
            }
            self.init(rawValue: attrPointer)
        }

        /// Gets the flags.
        public func getFlags() throws -> POSIXSpawnFlags {
            let flagsPointer = UnsafeMutablePointer<Int16>.allocate(capacity: 1)
            defer { flagsPointer.deallocate() }
            try BSDCore.BSD.call(posix_spawnattr_getflags(self.rawValue, flagsPointer))
            return POSIXSpawnFlags(rawValue: flagsPointer.pointee)
        }

        /// Sets the flags.
        public func setFlags(_ flags: POSIXSpawnFlags) throws {
            try BSDCore.BSD.call(posix_spawnattr_setflags(self.rawValue, flags.rawValue))
        }

        /// Gets the default signal set.
        public func getDefaultSignalSet() throws -> sigset_t {
            let sigdefaultPointer = UnsafeMutablePointer<sigset_t>.allocate(capacity: 1)
            defer { sigdefaultPointer.deallocate() }
            sigemptyset(sigdefaultPointer)
            try BSDCore.BSD.call(posix_spawnattr_getsigdefault(self.rawValue, sigdefaultPointer))
            return sigdefaultPointer.pointee
        }

        /// Sets the default signal set.
        public func setDefaultSignalSet(_ sigdefault: consuming sigset_t) throws {
            try BSDCore.BSD.call(posix_spawnattr_setsigdefault(self.rawValue, &sigdefault))
        }

        /// Gets the process group ID.
        public func getProcessGroup() throws -> pid_t {
            let pgidPointer = UnsafeMutablePointer<pid_t>.allocate(capacity: 1)
            defer { pgidPointer.deallocate() }
            try BSDCore.BSD.call(posix_spawnattr_getpgroup(self.rawValue, pgidPointer))
            return pgidPointer.pointee
        }

        /// Sets the process group ID.
        public func setProcessGroup(_ pgid: pid_t) throws {
            try BSDCore.BSD.call(posix_spawnattr_setpgroup(self.rawValue, pgid))
        }

        /// Gets the signal mask.
        public func getSignalMask() throws -> sigset_t {
            let sigmaskPointer = UnsafeMutablePointer<sigset_t>.allocate(capacity: 1)
            defer { sigmaskPointer.deallocate() }
            sigemptyset(sigmaskPointer)
            try BSDCore.BSD.call(posix_spawnattr_getsigmask(self.rawValue, sigmaskPointer))
            return sigmaskPointer.pointee
        }

        /// Sets the signal mask.
        public func setSignalMask(_ sigmask: consuming sigset_t) throws {
            try BSDCore.BSD.call(posix_spawnattr_setsigmask(self.rawValue, &sigmask))
        }

        // Gets the binary preferences.
        public func getBinaryPreferences() throws -> [cpu_type_t] {
            let preferencesCount = 4  // This is the documented maximum for binary preferences.
            let binaryPreferencePointer =
                UnsafeMutablePointer<cpu_type_t>.allocate(capacity: preferencesCount)
            let returnedCountPointer =
                UnsafeMutablePointer<Int>.allocate(capacity: 1)
            defer {
                binaryPreferencePointer.deallocate()
                returnedCountPointer.deallocate()
            }
            try BSDCore.BSD.call(
                posix_spawnattr_getbinpref_np(
                    self.rawValue, preferencesCount, binaryPreferencePointer, returnedCountPointer
                )
            )
            let returnedCount = returnedCountPointer.pointee
            let binaryPreferences = Array(
                UnsafeBufferPointer(
                    start: binaryPreferencePointer,
                    count: returnedCount
                )
            )
            return returnedCount == 0 ? [] : binaryPreferences
        }

        /// Sets the binary preferences.
        public func setBinaryPreferences(
            _ binaryPreferences: [cpu_type_t]
        ) throws {
            let preferencesCount = binaryPreferences.count
            let cpuTypeArrayPointer =
                UnsafeMutablePointer<cpu_type_t>.allocate(capacity: preferencesCount)
            let actuallySetCountPointer =
                UnsafeMutablePointer<Int>.allocate(capacity: 1)
            defer {
                cpuTypeArrayPointer.deallocate()
                actuallySetCountPointer.deallocate()
            }
            cpuTypeArrayPointer.initialize(from: binaryPreferences, count: preferencesCount)
            try BSDCore.BSD.call(
                posix_spawnattr_setbinpref_np(
                    self.rawValue, preferencesCount, cpuTypeArrayPointer, actuallySetCountPointer
                )
            )
            let actuallySetCount = actuallySetCountPointer.pointee
            if actuallySetCount < preferencesCount {
                // If not all preferences were set, something went wrong. We got past the return
                //  code check above, but we still want to alert the user as not all preferences
                //  being set is an unexpected state. We simulate a kernel "too big" error.
                throw POSIXError(.E2BIG)
            }
            // We don't check if actuallySetCount is *greater* than preferencesCount. If that
            //  actually happens, we have much bigger problems. We'll just ignore it for now.
        }

        // Gets the binary preferences.
        @available(macOS 11.0, iOS 14.0, *)
        public func getBinaryPreferences() throws -> [(
            cpuType: cpu_type_t, cpuSubType: cpu_subtype_t
        )] {
            let preferencesCount = 4  // This is the documented maximum for binary preferences.
            let cpuTypeArrayPointer =
                UnsafeMutablePointer<cpu_type_t>.allocate(capacity: preferencesCount)
            let cpuSubtypeArrayPointer =
                UnsafeMutablePointer<cpu_subtype_t>.allocate(capacity: preferencesCount)
            let returnedCountPointer =
                UnsafeMutablePointer<Int>.allocate(capacity: 1)
            defer {
                cpuTypeArrayPointer.deallocate()
                returnedCountPointer.deallocate()
            }
            try BSDCore.BSD.call(
                posix_spawnattr_getarchpref_np(
                    self.rawValue, preferencesCount,
                    cpuTypeArrayPointer, cpuSubtypeArrayPointer,
                    returnedCountPointer
                )
            )
            let returnedCount = returnedCountPointer.pointee
            let cpuTypeArray = Array(
                UnsafeBufferPointer(
                    start: cpuTypeArrayPointer,
                    count: returnedCount
                )
            )
            let cpuSubtypeArray = Array(
                UnsafeBufferPointer(
                    start: cpuSubtypeArrayPointer,
                    count: returnedCount
                )
            )
            let binaryPreferences = zip(cpuTypeArray, cpuSubtypeArray)
                .map { (cpuType: $0, cpuSubType: $1) }
            return returnedCount == 0 ? [] : binaryPreferences
        }

        /// Sets the binary preferences.
        @available(macOS 11.0, iOS 14.0, *)
        public func setBinaryPreferences(
            _ binaryPreferences: [(cpuType: cpu_type_t, cpuSubType: cpu_subtype_t)]
        ) throws {
            let preferencesCount = binaryPreferences.count
            let cpuTypeArrayPointer =
                UnsafeMutablePointer<cpu_type_t>.allocate(capacity: preferencesCount)
            let cpuSubtypeArrayPointer =
                UnsafeMutablePointer<cpu_subtype_t>.allocate(capacity: preferencesCount)
            let actuallySetCountPointer =
                UnsafeMutablePointer<Int>.allocate(capacity: 1)
            defer {
                cpuTypeArrayPointer.deallocate()
                cpuSubtypeArrayPointer.deallocate()
                actuallySetCountPointer.deallocate()
            }
            for (index, preference) in binaryPreferences.enumerated() {
                cpuTypeArrayPointer[index] = preference.cpuType
                cpuSubtypeArrayPointer[index] = preference.cpuSubType
            }
            try BSDCore.BSD.call(
                posix_spawnattr_setarchpref_np(
                    self.rawValue, preferencesCount,
                    cpuTypeArrayPointer, cpuSubtypeArrayPointer,
                    actuallySetCountPointer
                )
            )
            let actuallySetCount = actuallySetCountPointer.pointee
            if actuallySetCount < preferencesCount {
                // If not all preferences were set, something went wrong. We got past the return
                //  code check above, but we still want to alert the user as not all preferences
                //  being set is an unexpected state. We simulate a kernel "too big" error.
                throw POSIXError(.E2BIG)
            }
            // We don't check if actuallySetCount is *greater* than preferencesCount. If that
            //  actually happens, we have much bigger problems. We'll just ignore it for now.
        }

        /// Sets the audit session port for the spawned process.
        public func setAuditSessionPort(_ auditSessionPort: MachCore.Mach.Port) throws {
            try BSDCore.BSD.call(
                posix_spawnattr_setauditsessionport_np(self.rawValue, auditSessionPort.name)
            )
        }

        /// Sets an exception port for the spawned process.
        public func setExceptionPort(_ port: MachCore.Mach.ExceptionPort) throws {
            try BSDCore.BSD.call(
                posix_spawnattr_setexceptionports_np(
                    self.rawValue, port.mask.rawValue, port.name,
                    port.behavior.rawValue,
                    port.threadStateFlavor
                )
            )
        }

        /// Sets a special port for the spawned process.
        public func setSpecialPort(
            _ specialPort: MachCore.Mach.TaskSpecialPort, to port: MachCore.Mach.Port
        ) throws {
            try BSDCore.BSD.call(
                posix_spawnattr_setspecialport_np(self.rawValue, port.name, specialPort.rawValue)
            )
        }

        /// Sets the CPU security mitigations for the spawned process.
        @available(macOS 11.0, iOS 14.0, *)
        public func setCPUSecurityMitigations(flags: POSIXSpawnCPUSecurityMitigations) throws {
            try BSDCore.BSD.call(posix_spawnattr_set_csm_np(self.rawValue, flags.rawValue))
        }

        deinit { let _ = try? BSDCore.BSD.call(posix_spawnattr_destroy(self.rawValue)) }
    }

    // MARK: - POSIXSpawnFileActions

    /// File actions for a POSIX spawn call.
    public final class POSIXSpawnFileActions: RawRepresentable {
        /// The raw file actions.
        public var rawValue: UnsafeMutablePointer<posix_spawn_file_actions_t?>

        /// Initializes a new POSIX spawn file actions object with the given raw value.
        public init(rawValue: UnsafeMutablePointer<posix_spawn_file_actions_t?>) {
            self.rawValue = rawValue
        }

        /// Initializes a new POSIX spawn file actions object.
        public convenience init() throws {
            let fileActionsPointer =
                UnsafeMutablePointer<posix_spawn_file_actions_t?>.allocate(capacity: 1)
            try BSDCore.BSD.call(posix_spawn_file_actions_init(fileActionsPointer))
            guard fileActionsPointer.pointee != nil else {
                // If we somehow got past the return code check above, but the raw value is still
                //  nil, we have a problem. We simulate a kernel memory error.
                throw POSIXError(.ENOMEM)
            }
            self.init(rawValue: fileActionsPointer)
        }

        /// Adds an action to close a file descriptor.
        public func addClose(fd: Int32) throws {
            try BSDCore.BSD.call(posix_spawn_file_actions_addclose(self.rawValue, fd))
        }

        /// Adds an action to close a file descriptor.
        @available(macOS 11.0, iOS 14.0, *)
        public func addClose(fd: FileDescriptor) throws {
            try BSDCore.BSD.call(posix_spawn_file_actions_addclose(self.rawValue, fd.rawValue))
        }

        /// Adds an action to duplicate a file descriptor.
        public func addDup2(fd: Int32, toFD newFD: Int32) throws {
            try BSDCore.BSD.call(
                posix_spawn_file_actions_adddup2(self.rawValue, fd, newFD)
            )
        }

        /// Adds an action to open a file.
        public func addOpen(
            path: String, usingFD fd: Int32, flags: Int32, mode: mode_t
        ) throws {
            try BSDCore.BSD.call(
                posix_spawn_file_actions_addopen(
                    self.rawValue, fd, path, flags, mode
                )
            )
        }

        /// Adds an action to open a file.
        @available(macOS 11.0, iOS 14.0, *)
        public func addOpen(
            path: String,
            usingFD fd: FileDescriptor.RawValue,
            flags: FileDescriptor.OpenOptions,
            mode: FilePermissions
        ) throws {
            try BSDCore.BSD.call(
                posix_spawn_file_actions_addopen(
                    self.rawValue, fd, path, flags.rawValue, mode.rawValue
                )
            )
        }

        /// Adds an action to inherit a file descriptor.
        public func addInherit(fd: Int32) throws {
            try BSDCore.BSD.call(posix_spawn_file_actions_addinherit_np(self.rawValue, fd))
        }

        /// Adds an action to inherit a file descriptor.
        @available(macOS 11.0, iOS 14.0, *)
        public func addInherit(fd: FileDescriptor) throws {
            try BSDCore.BSD.call(posix_spawn_file_actions_addinherit_np(self.rawValue, fd.rawValue))
        }

        /// Adds an action to change the working directory.
        @available(macOS 10.15, *)
        @available(iOS, unavailable)
        public func addChangeDirectory(toPath path: String) throws {
            try BSDCore.BSD.call(
                posix_spawn_file_actions_addchdir_np(self.rawValue, path)
            )
        }

        /// Adds an action to change the working directory.
        @available(macOS 10.15, *)
        @available(iOS, unavailable)
        public func addChangeDirectory(toFD fd: Int32) throws {
            try BSDCore.BSD.call(
                posix_spawn_file_actions_addfchdir_np(self.rawValue, fd)
            )
        }

        /// Adds an action to change the working directory.
        @available(macOS 11.0, iOS 14.0, *)
        @available(iOS, unavailable)
        public func addChangeDirectory(toFD fd: FileDescriptor) throws {
            try BSDCore.BSD.call(
                posix_spawn_file_actions_addfchdir_np(self.rawValue, fd.rawValue)
            )
        }

        deinit { let _ = try? BSDCore.BSD.call(posix_spawn_file_actions_destroy(self.rawValue)) }
    }

    // MARK: - POSIXSpawn

    /// Spawns a new process using the "POSIX spawn" system call.
    public static func posixSpawn(
        path: String, fileActions: POSIXSpawnFileActions, attributes: POSIXSpawnAttributes,
        arguments: [String], environmentVariables: [String: String]
    ) throws -> pid_t {
        let argv = arguments.map { $0.withCString(strdup) }
        let envp = environmentVariables.map { "\($0.key)=\($0.value)".withCString(strdup) }
        defer {
            for arg in argv { free(arg) }
            for env in envp { free(env) }
        }

        let pidPointer = UnsafeMutablePointer<pid_t>.allocate(capacity: 1)
        defer { pidPointer.deallocate() }
        try BSDCore.BSD.call(
            posix_spawn(
                pidPointer,
                path,
                fileActions.rawValue,
                attributes.rawValue,
                argv + [nil],
                envp + [nil]
            ),
            returnsErrno: true
        )
        return pidPointer.pointee
    }
}
