import Foundation
import KassC.CSBlobs
import KassC.SpawnInternal
import KassC.SpawnPrivate
import KassHelpers
import MachCore
import System

extension cs_launch_type_t {
    /// No launch type.
    public static let none = Self.CS_LAUNCH_TYPE_NONE

    /// The launch type of a system service.
    public static let systemService = Self.CS_LAUNCH_TYPE_SYSTEM_SERVICE

    /// The launch type of sysdiagnose.
    public static let sysdiagnose = Self.CS_LAUNCH_TYPE_SYSDIAGNOSE

    /// The launch type of an application.
    public static let application = Self.CS_LAUNCH_TYPE_APPLICATION
}

extension BSD {
    /// An option for what to do with a spawned process upon resource starvation.
    public struct POSIXSpawnProcessControlOption: KassHelpers.NamedOptionEnum {
        /// The name of the option, if it can be determined.
        public var name: String?

        /// Represents a process control option with an optional name.
        public init(name: String?, rawValue: Int32) {
            self.name = name
            self.rawValue = rawValue
        }

        /// The raw value of the option.
        public let rawValue: Int32

        /// All known process control options.
        public static let allCases: [Self] = [.none, .throttle, .suspend, .kill]

        /// Does nothing to the spawned process upon resource starvation.
        public static let none = Self(name: "none", rawValue: POSIX_SPAWN_PCONTROL_NONE)

        /// Throttles the spawned process upon resource starvation.
        public static let throttle = Self(name: "throttle", rawValue: POSIX_SPAWN_PCONTROL_THROTTLE)

        /// Suspends the spawned process upon resource starvation.
        public static let suspend = Self(name: "suspend", rawValue: POSIX_SPAWN_PCONTROL_SUSPEND)

        /// Kills the spawned process upon resource starvation.
        public static let kill = Self(name: "kill", rawValue: POSIX_SPAWN_PCONTROL_KILL)
    }

    /// A process type for a spawned process.
    public struct POSIXSpawnProcessType: KassHelpers.NamedOptionEnum {
        /// The name of the type, if it can be determined.
        public var name: String?

        /// Represents a process type with an optional name.
        public init(name: String?, rawValue: Int32) {
            self.name = name
            self.rawValue = rawValue
        }

        /// The raw value of the type.
        public let rawValue: Int32

        /// All known process types.
        public static let allCases: [Self] = []

        /// The process is a normal process.
        public static let normal = Self(
            name: "normal", rawValue: POSIX_SPAWN_PROCESS_TYPE_NORMAL
        )

        /// The default process type.
        public static let `default` = Self(
            name: "default", rawValue: POSIX_SPAWN_PROCESS_TYPE_DEFAULT
        )

        /// The process is an app.
        public static let defaultApp = Self(
            name: "appDefault", rawValue: POSIX_SPAWN_PROC_TYPE_APP_DEFAULT
        )

        /// The process is an app with a transparent app lifecycle.
        /// - Note: This is unused in the latest versions of the kernel.
        public static let transparentAppLifecycleApp = Self(
            name: "transparentAppLifecycleApp", rawValue: POSIX_SPAWN_PROC_TYPE_APP_TAL
        )

        public static let standardDaemon = Self(
            name: "daemon", rawValue: POSIX_SPAWN_PROC_TYPE_DAEMON_STANDARD
        )

        public static let interactiveDaemon = Self(
            name: "interactiveDaemon", rawValue: POSIX_SPAWN_PROC_TYPE_DAEMON_INTERACTIVE
        )

        public static let backgroundDaemon = Self(
            name: "backgroundDaemon", rawValue: POSIX_SPAWN_PROC_TYPE_DAEMON_BACKGROUND
        )

        public static let adaptiveDaemon = Self(
            name: "adaptiveDaemon", rawValue: POSIX_SPAWN_PROC_TYPE_DAEMON_ADAPTIVE
        )
    }

}

extension BSD.POSIXSpawnAttributes {
    /// Gets the process control option for the spawned process.
    public func getProcessControl() throws -> BSD.POSIXSpawnProcessControlOption {
        let processControlPointer = UnsafeMutablePointer<Int32>.allocate(capacity: 1)
        defer { processControlPointer.deallocate() }
        try BSDCore.BSD.call(posix_spawnattr_getpcontrol_np(self.rawValue, processControlPointer))
        return BSD.POSIXSpawnProcessControlOption(rawValue: processControlPointer.pointee)
    }

    /// Sets the process control option for the spawned process.
    public func setProcessControl(_ processControl: BSD.POSIXSpawnProcessControlOption) throws {
        try BSDCore.BSD.call(posix_spawnattr_setpcontrol_np(self.rawValue, processControl.rawValue))
    }

    /// Gets the process type for the spawned process.
    public func getProcessType() throws -> BSD.POSIXSpawnProcessType {
        let processTypePointer = UnsafeMutablePointer<Int32>.allocate(capacity: 1)
        defer { processTypePointer.deallocate() }
        try BSDCore.BSD.call(posix_spawnattr_getprocesstype_np(self.rawValue, processTypePointer))
        return BSD.POSIXSpawnProcessType(rawValue: processTypePointer.pointee)
    }

    /// Sets the process type for the spawned process.
    public func setProcessType(_ processType: BSD.POSIXSpawnProcessType) throws {
        try BSDCore.BSD.call(posix_spawnattr_setprocesstype_np(self.rawValue, processType.rawValue))
    }

    /// Gets the CPU monitor setting for the spawned process.
    public func getCPUMonitor() throws -> (percentage: UInt64, interval: UInt64) {
        let percentagePointer = UnsafeMutablePointer<UInt64>.allocate(capacity: 1)
        let intervalPointer = UnsafeMutablePointer<UInt64>.allocate(capacity: 1)
        defer {
            percentagePointer.deallocate()
            intervalPointer.deallocate()
        }
        try BSDCore.BSD.call(
            posix_spawnattr_getcpumonitor(self.rawValue, percentagePointer, intervalPointer))
        return (percentagePointer.pointee, intervalPointer.pointee)
    }

    /// Sets the CPU monitor setting for the spawned process.
    public func setCPUMonitor(percentage: UInt64, interval: UInt64) throws {
        try BSDCore.BSD.call(posix_spawnattr_setcpumonitor(self.rawValue, percentage, interval))
    }

    /// Sets the CPU monitor to the default setting for the spawned process.
    public func setCPUMonitorDefault() throws {
        try BSDCore.BSD.call(posix_spawnattr_setcpumonitor_default(self.rawValue))
    }

    /// Sets the jetsam settings for the spawned process.
    public func setJetsam(
        flags: Int16, priority: Int32, memoryLimits: (active: Int32, inactive: Int32)
    ) throws {
        try BSDCore.BSD.call(
            posix_spawnattr_setjetsam_ext(
                self.rawValue, flags, priority, memoryLimits.active, memoryLimits.inactive
            )
        )
    }

    /// Sets the jetsam TTRs for the spawned process.
    @available(macOS 10.15, iOS 13.0, *)
    public func setJetsamTTRs(_ ttrs: consuming [UInt32]) throws {
        try BSDCore.BSD.call(
            posix_spawnattr_set_jetsam_ttr_np(
                self.rawValue, UInt32(ttrs.count), &ttrs
            )
        )
    }

    /// Sets the thread limit for the spawned process.
    @available(macOS 10.14, *)
    public func setThreadLimit(_ threadLimit: Int32) throws {
        try BSDCore.BSD.call(posix_spawnattr_set_threadlimit_ext(self.rawValue, threadLimit))
    }

    /// Sets the kqueue workloop limits for the spawned process.
    @available(macOS 14.3, iOS 17.4, *)
    public func setKQueueWorkloopLimits(soft: UInt32, hard: UInt32) throws {
        try BSDCore.BSD.call(posix_spawnattr_set_kqworklooplimit_ext(self.rawValue, soft, hard))
    }

    /// Sets the importance watch ports for the spawned process.
    public func setImportanceWatchPorts(_ ports: [MachCore.Mach.Port]) throws {
        let portNameArrayPointer = mach_port_name_array_t.allocate(capacity: ports.count)
        defer { portNameArrayPointer.deallocate() }
        portNameArrayPointer.initialize(from: ports.map { port in port.name }, count: ports.count)
        try BSDCore.BSD.call(
            posix_spawnattr_set_importancewatch_port_np(
                self.rawValue, Int32(ports.count), portNameArrayPointer
            )
        )
    }

    /// Sets the registered ports for the spawned process.
    @available(macOS 10.15, iOS 13.0, *)
    public func setRegisteredPorts(_ ports: [MachCore.Mach.Port]) throws {
        let portNameArrayPointer = mach_port_name_array_t.allocate(capacity: ports.count)
        defer { portNameArrayPointer.deallocate() }
        portNameArrayPointer.initialize(from: ports.map { port in port.name }, count: ports.count)
        try BSDCore.BSD.call(
            posix_spawnattr_set_registered_ports_np(
                self.rawValue, portNameArrayPointer, UInt32(ports.count)
            )
        )
    }

    /// Sets the port limits for the spawned process.
    @available(macOS 12.0, iOS 15.0, *)
    public func setPortLimits(softLimit: UInt32, hardLimit: UInt32) throws {
        try BSDCore.BSD.call(
            posix_spawnattr_set_portlimits_ext(self.rawValue, softLimit, hardLimit))
    }

    /// Sets the file descriptor limits for the spawned process.
    @available(macOS 12.0, iOS 15.0, *)
    public func setFileDescriptorLimits(softLimit: UInt32, hardLimit: UInt32) throws {
        try BSDCore.BSD.call(
            posix_spawnattr_set_filedesclimit_ext(self.rawValue, softLimit, hardLimit))
    }

    /// Gets the MAC policy information for the spawned process.
    public func getMACPolicyInfo() throws -> (policyName: String, policyData: Data) {
        let macPolicyInfoPointer = UnsafeMutablePointer<Int32>.allocate(capacity: 1)
        let macPolicyNamePointer = UnsafeMutablePointer<Int8>.allocate(capacity: 128)
        let macPolicyDataPointer =
            UnsafeMutablePointer<UnsafeMutableRawPointer?>.allocate(capacity: 1)
        let macPolicyDataSizePointer = UnsafeMutablePointer<size_t>.allocate(capacity: 1)
        defer {
            macPolicyInfoPointer.deallocate()
            macPolicyNamePointer.deallocate()
            macPolicyDataPointer.deallocate()
            macPolicyDataSizePointer.deallocate()
        }
        try BSDCore.BSD.call(
            posix_spawnattr_getmacpolicyinfo_np(
                self.rawValue, macPolicyNamePointer, macPolicyDataPointer, macPolicyDataSizePointer
            )
        )
        let policyName = String(cString: macPolicyNamePointer)
        let policyDataSize = macPolicyDataSizePointer.pointee
        let policyData = Data(
            bytes: macPolicyDataPointer, count: policyDataSize)
        return (policyName, policyData)
    }

    /// Sets the MAC policy information for the spawned process.
    public func setMACPolicyInfo(
        policyName: String, policyData: Data
    ) throws {
        try policyData.withUnsafeBytes { bytes in
            let _ = try BSDCore.BSD.call(
                posix_spawnattr_setmacpolicyinfo_np(
                    self.rawValue, policyName,
                    UnsafeMutableRawPointer(mutating: bytes.baseAddress!),
                    bytes.count
                )
            )
        }
    }

    /// Sets the coalition information for the spawned process.
    public func setCoalition(coalitionID: UInt64, type: Int32, role: Int32) throws {
        try BSDCore.BSD.call(
            posix_spawnattr_setcoalition_np(self.rawValue, coalitionID, type, role))
    }

    /// Gets the QOS clamp setting for the spawned process.
    public func getQOSClamp() throws -> UInt64 {
        let qosClampPointer = UnsafeMutablePointer<UInt64>.allocate(capacity: 1)
        defer { qosClampPointer.deallocate() }
        try BSDCore.BSD.call(posix_spawnattr_get_qos_clamp_np(self.rawValue, qosClampPointer))
        return qosClampPointer.pointee
    }

    /// Sets the QOS clamp setting for the spawned process.
    public func setQOSClamp(_ qosClamp: UInt64) throws {
        try BSDCore.BSD.call(posix_spawnattr_set_qos_clamp_np(self.rawValue, qosClamp))
    }

    /// Gets the Darwin role for the spawned process.
    public func getDarwinRole() throws -> BSD.DarwinRole {
        let darwinRolePointer = UnsafeMutablePointer<UInt64>.allocate(capacity: 1)
        defer { darwinRolePointer.deallocate() }
        try BSDCore.BSD.call(posix_spawnattr_get_darwin_role_np(self.rawValue, darwinRolePointer))
        return BSD.DarwinRole(rawValue: Int32(darwinRolePointer.pointee))
    }

    /// Sets the Darwin role for the spawned process.
    public func setDarwinRole(_ darwinRole: BSD.DarwinRole) throws {
        try BSDCore.BSD.call(
            posix_spawnattr_set_darwin_role_np(self.rawValue, UInt64(darwinRole.rawValue)))
    }

    /// Sets the persona for the spawned process.
    public func setPersona(personaID: uid_t, flags: UInt32) throws {
        try BSDCore.BSD.call(posix_spawnattr_set_persona_np(self.rawValue, personaID, flags))
    }

    /// Sets the persona UID for the spawned process.
    public func setPersonaUID(_ uid: uid_t) throws {
        try BSDCore.BSD.call(posix_spawnattr_set_persona_uid_np(self.rawValue, uid))
    }

    /// Sets the persona GID for the spawned process.
    public func setPersonaGID(_ gid: gid_t) throws {
        try BSDCore.BSD.call(posix_spawnattr_set_persona_gid_np(self.rawValue, gid))
    }

    /// Sets the persona groups for the spawned process.
    public func setPersonaGroups(_ groups: [gid_t], uid: uid_t) throws {
        let gidArrayPointer = UnsafeMutablePointer<gid_t>.allocate(capacity: groups.count)
        defer { gidArrayPointer.deallocate() }
        gidArrayPointer.initialize(from: groups, count: groups.count)
        try BSDCore.BSD.call(
            posix_spawnattr_set_persona_groups_np(
                self.rawValue, Int32(groups.count), gidArrayPointer, uid
            )
        )
    }

    /// Sets the max address for the spawned process.
    @available(macOS 10.14, *)
    public func setMaxAddress(_ maxAddress: UInt64) throws {
        try BSDCore.BSD.call(posix_spawnattr_set_max_addr_np(self.rawValue, maxAddress))
    }

    /// Sets the UID for the spawned process.
    @available(macOS 10.15, iOS 13.0, *)
    public func setUID(_ uid: uid_t) throws {
        try BSDCore.BSD.call(posix_spawnattr_set_uid_np(self.rawValue, uid))
    }

    /// Sets the GID for the spawned process.
    @available(macOS 10.15, iOS 13.0, *)
    public func setGID(_ gid: gid_t) throws {
        try BSDCore.BSD.call(posix_spawnattr_set_gid_np(self.rawValue, gid))
    }

    /// Sets the groups for the spawned process.
    @available(macOS 10.15, iOS 13.0, *)
    public func setGroups(_ groups: [gid_t], uid: uid_t) throws {
        let gidArrayPointer = UnsafeMutablePointer<gid_t>.allocate(capacity: groups.count)
        defer { gidArrayPointer.deallocate() }
        gidArrayPointer.initialize(from: groups, count: groups.count)
        try BSDCore.BSD.call(
            posix_spawnattr_set_groups_np(self.rawValue, Int32(groups.count), gidArrayPointer, uid)
        )
    }

    /// Sets the login name for the spawned process.
    @available(macOS 10.15, iOS 13.0, *)
    public func setLogin(_ login: String) throws {
        try BSDCore.BSD.call(posix_spawnattr_set_login_np(self.rawValue, login))
    }

    /// Sets the subsystem root path for the spawned process.
    @available(macOS 11.0, iOS 14.0, *)
    public func setSubsystemRootPath(_ path: String) throws {
        try path.withCString { pathCString in
            let _ = try BSDCore.BSD.call(
                posix_spawnattr_set_subsystem_root_path_np(
                    self.rawValue, UnsafeMutablePointer(mutating: pathCString))
            )
        }
    }

    /// Sets the platform for the spawned process.
    @available(macOS 11.0, iOS 14.0, *)
    public func setPlatform(_ platform: Int32, flags: UInt32) throws {
        try BSDCore.BSD.call(posix_spawnattr_set_platform_np(self.rawValue, platform, flags))
    }

    /// Disables the use of pointer authentication A keys for the spawned process.
    @available(macOS 11.0, iOS 14.0, *)
    public func disablePointerAuthenticationAKeys(flags: UInt32) throws {
        try BSDCore.BSD.call(posix_spawnattr_disable_ptr_auth_a_keys_np(self.rawValue, flags))
    }

    /// Sets the use of the alternative Rosetta runtime for the spawned process.
    @available(macOS 12.0, iOS 15.0, *)
    public func useAlternativeRosettaRuntime(flags: UInt32) throws {
        try BSDCore.BSD.call(posix_spawnattr_set_alt_rosetta_np(self.rawValue, flags))
    }

    /// Sets the crash count for the spawned process.
    @_spi_available(macOS 13.1, *)
    public func setCrashCount(_ count: UInt32, timeout: UInt32) throws {
        try BSDCore.BSD.call(posix_spawnattr_set_crash_count_np(self.rawValue, count, timeout))
    }

    /// Sets the crash behavior for the spawned process.
    @available(macOS 13.0, iOS 16.0, *)
    public func setCrashBehavior(_ behavior: UInt32) throws {
        try BSDCore.BSD.call(posix_spawnattr_set_crash_behavior_np(self.rawValue, behavior))
    }

    /// Sets the crash behavior deadline for the spawned process.
    @available(macOS 13.0, iOS 16.0, *)
    public func setCrashBehaviorDeadline(_ deadline: UInt64, flags: UInt32) throws {
        try BSDCore.BSD.call(
            posix_spawnattr_set_crash_behavior_deadline_np(self.rawValue, deadline, flags))
    }

    /// Sets the launch type for the spawned process.
    @_spi_available(macOS 13.0, *)
    public func setLaunchType(_ type: cs_launch_type_t) throws {
        try BSDCore.BSD.call(posix_spawnattr_set_launch_type_np(self.rawValue, type.rawValue))
    }

    /// Sets the use of security shims for the spawned process.
    @_spi_available(macOS 14.0, *)
    public func setUseSecurityShims(flags: UInt32) throws {
        try BSDCore.BSD.call(posix_spawnattr_set_use_sec_transition_shims_np(self.rawValue, flags))
    }

    /// Sets policy for the use of the dataless file materialization for the spawned process.
    @_spi_available(macOS 13.3, *)
    public func setDatalessFileMaterializationIOPolicy(
        _ policy: BSD.DatalessFileMaterializationIOPolicy
    ) throws {
        try BSDCore.BSD.call(
            posix_spawnattr_setdataless_iopolicy_np(self.rawValue, policy.rawValue)
        )
    }

    /// Sets the conclave ID for the spawned process.
    @_spi_available(macOS 14.0, *)
    public func setConclaveID(_ conclaveID: String) throws {
        try BSDCore.BSD.call(posix_spawnattr_set_conclave_id_np(self.rawValue, conclaveID))
    }
}

extension BSD.POSIXSpawnAttributes {
    /// Adds an action to duplicate a fileport to a file descriptor.
    @available(macOS 10.15, iOS 13.0, *)
    public func addFilePortDup2(_ fileport: BSD.Fileport, toFD fd: Int32) throws {
        try BSDCore.BSD.call(
            posix_spawn_file_actions_add_fileportdup2_np(self.rawValue, fileport.name, fd)
        )
    }

    /// Adds an action to duplicate a fileport to a file descriptor.
    @available(macOS 11.0, iOS 14.0, *)
    public func addFilePortDup2(_ fileport: BSD.Fileport, toFD fd: FileDescriptor) throws {
        try BSDCore.BSD.call(
            posix_spawn_file_actions_add_fileportdup2_np(self.rawValue, fileport.name, fd.rawValue)
        )
    }
}
