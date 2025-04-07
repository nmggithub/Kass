import Darwin.POSIX
import KassC.ResourcePrivate
import KassHelpers

extension BSD {
    // MARK: - Policy Type

    /// An I/O policy type.
    public struct IOPolicyType: KassHelpers.NamedOptionEnum {
        /// The name of the policy type, if it can be determined.
        public var name: String?

        /// Represents an I/O policy type with an optional name.
        public init(name: String?, rawValue: Int32) {
            self.name = name
            self.rawValue = rawValue
        }

        /// The raw value of the policy type.
        public let rawValue: Int32

        /// All known I/O policy types.
        public static let allCases: [Self] = []

        public static let disk = Self(
            name: "disk", rawValue: IOPOL_TYPE_DISK
        )

        public static let accessTimeUpdates = Self(
            name: "accessTimeUpdates", rawValue: IOPOL_TYPE_VFS_ATIME_UPDATES
        )

        public static let materializeDataLessFiles = Self(
            name: "materializeDataLessFiles", rawValue: IOPOL_TYPE_VFS_MATERIALIZE_DATALESS_FILES
        )

        public static let statfsNoDataVolume = Self(
            name: "statfsNoDataVolume", rawValue: IOPOL_TYPE_VFS_STATFS_NO_DATA_VOLUME
        )

        public static let triggerResolve = Self(
            name: "triggerResolve", rawValue: IOPOL_TYPE_VFS_TRIGGER_RESOLVE
        )

        public static let ignoreContentProtection = Self(
            name: "ignoreContentProtection", rawValue: IOPOL_TYPE_VFS_IGNORE_CONTENT_PROTECTION
        )

        public static let ignorePermissions = Self(
            name: "ignorePermissions", rawValue: IOPOL_TYPE_VFS_IGNORE_PERMISSIONS
        )

        public static let skipModifiedTimeUpdates = Self(
            name: "skipModifiedTimeUpdates", rawValue: IOPOL_TYPE_VFS_SKIP_MTIME_UPDATE
        )

        public static let allowLowSpaceWrites = Self(
            name: "allowLowSpaceWrites", rawValue: IOPOL_TYPE_VFS_ALLOW_LOW_SPACE_WRITES
        )

        public static let disallowReadWriteForEventOnly = Self(
            name: "disallowReadWriteForEventOnly",
            rawValue: IOPOL_TYPE_VFS_DISALLOW_RW_FOR_O_EVTONLY
        )

        // Private policy types

        public static let hfsCaseSensitivity = Self(
            name: "hfsCaseSensitivity", rawValue: IOPOL_TYPE_VFS_HFS_CASE_SENSITIVITY
        )

        public static let alternativeSymlinks = Self(
            name: "alternativeSymlinks", rawValue: IOPOL_TYPE_VFS_ALTLINK
        )

        public static let blockSizeNoCacheWrites = Self(
            name: "blockSizeNoCacheWrites", rawValue: IOPOL_TYPE_VFS_NOCACHE_WRITE_FS_BLKSIZE
        )
    }

    // MARK: - Policy Scope

    /// An I/O policy scope.
    public struct IOPolicyScope: KassHelpers.NamedOptionEnum {
        /// The name of the policy scope, if it can be determined.
        public var name: String?

        /// Represents an I/O policy scope with an optional name.
        public init(name: String?, rawValue: Int32) {
            self.name = name
            self.rawValue = rawValue
        }

        /// The raw value of the policy scope.
        public let rawValue: Int32

        /// All known I/O policy scopes.
        public static let allCases: [Self] = [.process, .thread, .darwinBackground]

        /// The policy is scoped to the current process.
        public static let process = Self(
            name: "process", rawValue: IOPOL_SCOPE_PROCESS
        )

        /// The policy is scoped to the current thread.
        public static let thread = Self(
            name: "thread", rawValue: IOPOL_SCOPE_THREAD
        )

        /// The policy is scoped to the current process (as a background task).
        /// - Note: This really only makes sense for the ``IOPolicyType/disk`` policy type.
        public static let darwinBackground = Self(
            name: "darwinBackground", rawValue: IOPOL_SCOPE_DARWIN_BG
        )
    }

    /// MARK: Policy Get/Set

    /// Gets the I/O policy for a given type and scope.
    public static func getIOPolicy(
        forType type: IOPolicyType, andScope scope: IOPolicyScope
    ) throws -> Int32 {
        return try BSDCore.BSD.call(getiopolicy_np(type.rawValue, scope.rawValue))
    }

    /// Sets the I/O policy for a given type and scope to a given value.
    public static func setIOPolicy(
        forType type: IOPolicyType, andScope scope: IOPolicyScope, to value: Int32
    ) throws {
        try BSDCore.BSD.call(setiopolicy_np(type.rawValue, scope.rawValue, value))
    }

    /// MARK: - Disk Policy

    /// An I/O policy for disk I/O.
    public struct DiskIOPolicy: KassHelpers.NamedOptionEnum {
        /// The name of the I/O policy, if it can be determined.
        public var name: String?

        /// Represents a disk I/O policy with an optional name.
        public init(name: String?, rawValue: Int32) {
            self.name = name
            self.rawValue = rawValue
        }

        /// The raw value of the I/O policy.
        public let rawValue: Int32

        /// All known disk I/O policies.
        public static let allCases: [Self] = [
            .default,
            .important,
            .passive,
            .throttle,
            .utility,
            .standard,
            .normal,
        ]

        /// The default I/O policy.
        public static let `default` = Self(
            name: "default", rawValue: IOPOL_DEFAULT
        )

        /// The important I/O policy.
        public static let important = Self(
            name: "important", rawValue: IOPOL_IMPORTANT
        )

        /// The passive I/O policy.
        public static let passive = Self(
            name: "passive", rawValue: IOPOL_PASSIVE
        )

        /// The throttling I/O policy.
        public static let throttle = Self(
            name: "throttle", rawValue: IOPOL_THROTTLE
        )

        /// The utility I/O policy.
        public static let utility = Self(
            name: "utility", rawValue: IOPOL_UTILITY
        )

        /// The standard I/O policy.
        public static let standard = Self(
            name: "standard", rawValue: IOPOL_STANDARD
        )

        /// The normal I/O policy.
        public static let normal = Self(
            name: "normal", rawValue: IOPOL_NORMAL
        )
    }

    /// Gets the disk I/O policy for a given scope.
    public static func getDiskIOPolicy(forScope scope: IOPolicyScope) throws -> DiskIOPolicy {
        let rawValue = try getIOPolicy(forType: .disk, andScope: scope)
        return DiskIOPolicy(name: nil, rawValue: rawValue)
    }

    /// Sets the disk I/O policy for a given scope to a given value.
    public static func setDiskIOPolicy(forScope scope: IOPolicyScope, to value: DiskIOPolicy) throws
    {
        try setIOPolicy(forType: .disk, andScope: scope, to: value.rawValue)
    }

    /// MARK: - Access Time Updates

    /// An I/O policy for access time updates.
    public struct AccessTimeUpdatesIOPolicy: KassHelpers.NamedOptionEnum {
        /// The name of the policy, if it can be determined.
        public var name: String?

        /// Represents an access time updates I/O policy value with an optional name.
        public init(name: String?, rawValue: Int32) {
            self.name = name
            self.rawValue = rawValue
        }

        /// The raw value of the policy.
        public let rawValue: Int32

        /// All known access time updates I/O policies.
        public static let allCases: [Self] = [.default, .off]

        /// The default access time updates I/O policy.
        public static let `default` = Self(
            name: "default", rawValue: IOPOL_ATIME_UPDATES_DEFAULT
        )

        /// Disables access time updates.
        public static let off = Self(
            name: "off", rawValue: IOPOL_ATIME_UPDATES_OFF
        )
    }

    /// Gets the access time updates I/O policy for a given scope.
    public static func getAccessTimeUpdatesIOPolicy(
        forScope scope: IOPolicyScope
    ) throws -> AccessTimeUpdatesIOPolicy {
        let rawValue = try getIOPolicy(forType: .accessTimeUpdates, andScope: scope)
        return AccessTimeUpdatesIOPolicy(name: nil, rawValue: rawValue)
    }

    /// Sets the access time updates I/O policy for a given scope to a given value.
    public static func setAccessTimeUpdatesIOPolicy(
        forScope scope: IOPolicyScope, to value: AccessTimeUpdatesIOPolicy
    ) throws {
        try setIOPolicy(forType: .accessTimeUpdates, andScope: scope, to: value.rawValue)
    }

    /// MARK: - Dataless File Materialization

    /// An I/O policy for dataless file materialization.
    public struct DatalessFileMaterializationIOPolicy: KassHelpers.NamedOptionEnum {
        /// The name of the policy, if it can be determined.
        public var name: String?

        /// Represents a dataless file materialization I/O policy value with an optional name.
        public init(name: String?, rawValue: Int32) {
            self.name = name
            self.rawValue = rawValue
        }

        /// All known dataless file materialization I/O policies.
        public static let allCases: [Self] = [.default, .off, .on]

        /// The raw value of the policy.
        public let rawValue: Int32

        /// Sets dataless file materialization to the default state.
        public static let `default` = Self(
            name: "default", rawValue: IOPOL_MATERIALIZE_DATALESS_FILES_DEFAULT
        )

        /// Disables dataless file materialization.
        public static let off = Self(
            name: "off", rawValue: IOPOL_MATERIALIZE_DATALESS_FILES_OFF
        )

        /// Enables dataless file materialization.
        public static let on = Self(
            name: "on", rawValue: IOPOL_MATERIALIZE_DATALESS_FILES_ON
        )
    }

    /// Gets the dataless file materialization I/O policy for a given scope.
    public static func getDatalessFileMaterializationIOPolicy(
        forScope scope: IOPolicyScope
    ) throws -> DatalessFileMaterializationIOPolicy {
        let rawValue = try getIOPolicy(forType: .materializeDataLessFiles, andScope: scope)
        return DatalessFileMaterializationIOPolicy(name: nil, rawValue: rawValue)
    }

    /// Sets the dataless file materialization I/O policy for a given scope to a given value.
    public static func setDatalessFileMaterializationIOPolicy(
        forScope scope: IOPolicyScope, to value: DatalessFileMaterializationIOPolicy
    ) throws {
        try setIOPolicy(forType: .materializeDataLessFiles, andScope: scope, to: value.rawValue)
    }

    /// MARK: - statfs No Data Volume

    /// An I/O policy for no data volume in `statfs`.
    public struct StatfsNoDataVolumeIOPolicy: KassHelpers.NamedOptionEnum {
        /// The name of the policy, if it can be determined.
        public var name: String?

        /// Represents a `statfs` no data volume I/O policy value with an optional name.
        public init(name: String?, rawValue: Int32) {
            self.name = name
            self.rawValue = rawValue
        }

        /// The raw value of the policy.
        public let rawValue: Int32

        /// All known `statfs` no data volume I/O policies.
        public static let allCases: [Self] = [.default, .force]

        /// The default `statfs` no data volume I/O policy.
        public static let `default` = Self(
            name: "default", rawValue: IOPOL_VFS_STATFS_NO_DATA_VOLUME_DEFAULT
        )

        /// Forces `statfs` to show no data volume.
        public static let force = Self(
            name: "force", rawValue: IOPOL_VFS_STATFS_FORCE_NO_DATA_VOLUME
        )
    }

    /// Gets the `statfs` no data volume I/O policy for a given scope.
    public static func getStatfsNoDataVolumeIOPolicy(
        forScope scope: IOPolicyScope
    ) throws -> StatfsNoDataVolumeIOPolicy {
        let rawValue = try getIOPolicy(forType: .statfsNoDataVolume, andScope: scope)
        return StatfsNoDataVolumeIOPolicy(name: nil, rawValue: rawValue)
    }

    /// Sets the `statfs` no data volume I/O policy for a given scope to a given value.
    public static func setStatfsNoDataVolumeIOPolicy(
        forScope scope: IOPolicyScope, to value: StatfsNoDataVolumeIOPolicy
    ) throws {
        try setIOPolicy(forType: .statfsNoDataVolume, andScope: scope, to: value.rawValue)
    }

    /// MARK: - Trigger Resolution

    /// An I/O policy for trigger resolution.
    public struct TriggerResolutionIOPolicy: KassHelpers.NamedOptionEnum {
        /// The name of the policy, if it can be determined.
        public var name: String?

        /// Represents a trigger resolution I/O policy value with an optional name.
        public init(name: String?, rawValue: Int32) {
            self.name = name
            self.rawValue = rawValue
        }

        /// The raw value of the policy.
        public let rawValue: Int32

        /// All known trigger resolution I/O policies.
        public static let allCases: [Self] = [.default, .off]

        /// The default trigger resolution I/O policy.
        public static let `default` = Self(
            name: "default", rawValue: IOPOL_VFS_TRIGGER_RESOLVE_DEFAULT
        )

        /// Disables trigger resolution.
        public static let off = Self(
            name: "off", rawValue: IOPOL_VFS_TRIGGER_RESOLVE_OFF
        )
    }

    /// Gets the trigger resolution I/O policy for a given scope.
    public static func getTriggerResolutionIOPolicy(
        forScope scope: IOPolicyScope
    ) throws -> TriggerResolutionIOPolicy {
        let rawValue = try getIOPolicy(forType: .triggerResolve, andScope: scope)
        return TriggerResolutionIOPolicy(name: nil, rawValue: rawValue)
    }

    /// Sets the trigger resolution I/O policy for a given scope to a given value.
    public static func setTriggerResolutionIOPolicy(
        forScope scope: IOPolicyScope, to value: TriggerResolutionIOPolicy
    ) throws {
        try setIOPolicy(forType: .triggerResolve, andScope: scope, to: value.rawValue)
    }

    /// MARK: - Content Protection

    /// An I/O policy for content protection.
    public struct ContentProtectionIOPolicy: KassHelpers.NamedOptionEnum {
        /// The name of the policy, if it can be determined.
        public var name: String?

        /// Represents a content protection I/O policy value with an optional name.
        public init(name: String?, rawValue: Int32) {
            self.name = name
            self.rawValue = rawValue
        }

        /// The raw value of the policy.
        public let rawValue: Int32

        /// All known content protection I/O policies.
        public static let allCases: [Self] = [.default, .ignore]

        /// The default content protection I/O policy.
        public static let `default` = Self(
            name: "default", rawValue: IOPOL_VFS_CONTENT_PROTECTION_DEFAULT
        )

        /// Ignores content protection.
        public static let ignore = Self(
            name: "ignore", rawValue: IOPOL_VFS_CONTENT_PROTECTION_IGNORE
        )
    }

    /// Gets the content protection I/O policy for a given scope.
    public static func getContentProtectionIOPolicy(
        forScope scope: IOPolicyScope
    ) throws -> ContentProtectionIOPolicy {
        let rawValue = try getIOPolicy(forType: .ignoreContentProtection, andScope: scope)
        return ContentProtectionIOPolicy(name: nil, rawValue: rawValue)
    }

    /// Sets the content protection I/O policy for a given scope to a given value.
    public static func setContentProtectionIOPolicy(
        forScope scope: IOPolicyScope, to value: ContentProtectionIOPolicy
    ) throws {
        try setIOPolicy(forType: .ignoreContentProtection, andScope: scope, to: value.rawValue)
    }

    /// MARK: - Permissions

    /// An I/O policy for ignoring permissions.
    public struct IgnorePermissionsIOPolicy: KassHelpers.NamedOptionEnum {
        /// The name of the policy, if it can be determined.
        public var name: String?

        /// Represents a permissions-ignoring I/O policy value with an optional name.
        public init(name: String?, rawValue: Int32) {
            self.name = name
            self.rawValue = rawValue
        }

        /// The raw value of the policy.
        public let rawValue: Int32

        /// All known permissions-ignoring I/O policies.
        public static let allCases: [Self] = [.off, .on]

        /// Doesn't ignore permissions.
        public static let off = Self(
            name: "off", rawValue: IOPOL_VFS_IGNORE_PERMISSIONS_OFF
        )

        /// Ignores permissions.
        public static let on = Self(
            name: "on", rawValue: IOPOL_VFS_IGNORE_PERMISSIONS_ON
        )
    }

    /// Gets the permissions I/O policy for a given scope.
    public static func getPermissionsIOPolicy(
        forScope scope: IOPolicyScope
    ) throws -> IgnorePermissionsIOPolicy {
        let rawValue = try getIOPolicy(forType: .ignorePermissions, andScope: scope)
        return IgnorePermissionsIOPolicy(name: nil, rawValue: rawValue)
    }

    /// Sets the permissions I/O policy for a given scope to a given value.
    public static func setPermissionsIOPolicy(
        forScope scope: IOPolicyScope, to value: IgnorePermissionsIOPolicy
    ) throws {
        try setIOPolicy(forType: .ignorePermissions, andScope: scope, to: value.rawValue)
    }

    /// MARK: - Modified Time Updates

    /// An I/O policy for modified time updates.
    public struct SkipModifiedTimeUpdatesIOPolicy: KassHelpers.NamedOptionEnum {
        /// The name of the policy, if it can be determined.
        public var name: String?

        /// Represents a modified time updates I/O policy value with an optional name.
        public init(name: String?, rawValue: Int32) {
            self.name = name
            self.rawValue = rawValue
        }

        /// The raw value of the policy.
        public let rawValue: Int32

        /// All known modified time updates I/O policies.
        public static let allCases: [Self] = [.off, on]

        /// Disables skipping of modified time updates.
        public static let off = Self(
            name: "off", rawValue: IOPOL_VFS_SKIP_MTIME_UPDATE_OFF
        )

        /// Enables skipping of modified time updates.
        public static let on = Self(
            name: "on", rawValue: IOPOL_VFS_SKIP_MTIME_UPDATE_ON
        )
    }

    /// Gets the skip modified time updates I/O policy for a given scope.
    public static func getSkipModifiedTimeUpdatesIOPolicy(
        forScope scope: IOPolicyScope
    ) throws -> SkipModifiedTimeUpdatesIOPolicy {
        let rawValue = try getIOPolicy(forType: .skipModifiedTimeUpdates, andScope: scope)
        return SkipModifiedTimeUpdatesIOPolicy(name: nil, rawValue: rawValue)
    }

    /// Sets the skip modified time updates I/O policy for a given scope to a given value.
    public static func setSkipModifiedTimeUpdatesIOPolicy(
        forScope scope: IOPolicyScope, to value: SkipModifiedTimeUpdatesIOPolicy
    ) throws {
        try setIOPolicy(forType: .skipModifiedTimeUpdates, andScope: scope, to: value.rawValue)
    }

    /// MARK: - Low Space Writes

    /// An I/O policy for low space writes.
    public struct AllowLowSpaceWritesIOPolicy: KassHelpers.NamedOptionEnum {
        /// The name of the policy, if it can be determined.
        public var name: String?

        /// Represents a low space writes I/O policy value with an optional name.
        public init(name: String?, rawValue: Int32) {
            self.name = name
            self.rawValue = rawValue
        }

        /// The raw value of the policy.
        public let rawValue: Int32

        /// All known low space writes I/O policies.
        public static let allCases: [Self] = [.off, .on]

        /// Disables low space writes.
        public static let off = Self(
            name: "off", rawValue: IOPOL_VFS_ALLOW_LOW_SPACE_WRITES_OFF
        )

        /// Enables low space writes.
        public static let on = Self(
            name: "on", rawValue: IOPOL_VFS_ALLOW_LOW_SPACE_WRITES_ON
        )
    }

    /// Gets the allow low space writes I/O policy for a given scope.
    public static func getAllowLowSpaceWritesIOPolicy(
        forScope scope: IOPolicyScope
    ) throws -> AllowLowSpaceWritesIOPolicy {
        let rawValue = try getIOPolicy(forType: .allowLowSpaceWrites, andScope: scope)
        return AllowLowSpaceWritesIOPolicy(name: nil, rawValue: rawValue)
    }

    /// Sets the allow low space writes I/O policy for a given scope to a given value.
    public static func setAllowLowSpaceWritesIOPolicy(
        forScope scope: IOPolicyScope, to value: AllowLowSpaceWritesIOPolicy
    ) throws {
        try setIOPolicy(forType: .allowLowSpaceWrites, andScope: scope, to: value.rawValue)
    }

    /// MARK: - Disallow Read/Write for Event Only

    /// An I/O policy for disallowing read/write for event-only opens.
    public struct DisallowReadWriteForEventOnlyIOPolicy: KassHelpers.NamedOptionEnum {
        /// The name of the policy, if it can be determined.
        public var name: String?

        /// Represents a disallow read/write for event-only opens I/O policy value with an optional name.
        public init(name: String?, rawValue: Int32) {
            self.name = name
            self.rawValue = rawValue
        }

        /// The raw value of the policy.
        public let rawValue: Int32

        /// All known disallow read/write for event-only opens I/O policies.
        public static let allCases: [Self] = [.default, .on]

        /// The default disallow read/write for event-only opens I/O policy.
        public static let `default` = Self(
            name: "default", rawValue: IOPOL_VFS_DISALLOW_RW_FOR_O_EVTONLY_DEFAULT
        )

        /// Enables disallow read/write for event-only opens.
        public static let on = Self(
            name: "on", rawValue: IOPOL_VFS_DISALLOW_RW_FOR_O_EVTONLY_ON
        )
    }

    /// Gets the disallow read/write for event-only opens I/O policy for a given scope.
    public static func getDisallowReadWriteForEventOnlyIOPolicy(
        forScope scope: IOPolicyScope
    ) throws -> DisallowReadWriteForEventOnlyIOPolicy {
        let rawValue = try getIOPolicy(forType: .disallowReadWriteForEventOnly, andScope: scope)
        return DisallowReadWriteForEventOnlyIOPolicy(name: nil, rawValue: rawValue)
    }

    /// Sets the disallow read/write for event-only opens I/O policy for a given scope to a given value.
    public static func setDisallowReadWriteForEventOnlyIOPolicy(
        forScope scope: IOPolicyScope, to value: DisallowReadWriteForEventOnlyIOPolicy
    ) throws {
        try setIOPolicy(
            forType: .disallowReadWriteForEventOnly, andScope: scope, to: value.rawValue)
    }

    /// MARK: - HFS Case Sensitivity

    /// An I/O policy for HFS case sensitivity.
    public struct HFSCaseSensitivityIOPolicy: KassHelpers.NamedOptionEnum {
        /// The name of the policy, if it can be determined.
        public var name: String?

        /// Represents an HFS case sensitivity I/O policy value with an optional name.
        public init(name: String?, rawValue: Int32) {
            self.name = name
            self.rawValue = rawValue
        }

        /// The raw value of the policy.
        public let rawValue: Int32

        /// All known HFS case sensitivity I/O policies.
        public static let allCases: [Self] = [.default, .force]

        /// The default HFS case sensitivity I/O policy.
        public static let `default` = Self(
            name: "default", rawValue: IOPOL_VFS_HFS_CASE_SENSITIVITY_DEFAULT
        )

        /// Forces HFS case sensitivity.
        public static let force = Self(
            name: "force", rawValue: IOPOL_VFS_HFS_CASE_SENSITIVITY_FORCE_CASE_SENSITIVE
        )
    }

    /// Gets the HFS case sensitivity I/O policy for a given scope.
    public static func getHFSCaseSensitivityIOPolicy(
        forScope scope: IOPolicyScope
    ) throws -> HFSCaseSensitivityIOPolicy {
        let rawValue = try getIOPolicy(forType: .hfsCaseSensitivity, andScope: scope)
        return HFSCaseSensitivityIOPolicy(name: nil, rawValue: rawValue)
    }

    /// Sets the HFS case sensitivity I/O policy for a given scope to a given value.
    public static func setHFSCaseSensitivityIOPolicy(
        forScope scope: IOPolicyScope, to value: HFSCaseSensitivityIOPolicy
    ) throws {
        try setIOPolicy(forType: .hfsCaseSensitivity, andScope: scope, to: value.rawValue)
    }

    /// MARK: - Alternative Symlinks

    /// An I/O policy for alternative symlinks.
    public struct AlternativeSymlinksIOPolicy: KassHelpers.NamedOptionEnum {
        /// The name of the policy, if it can be determined.
        public var name: String?

        /// Represents an alternative symlinks I/O policy value with an optional name.
        public init(name: String?, rawValue: Int32) {
            self.name = name
            self.rawValue = rawValue
        }

        /// The raw value of the policy.
        public let rawValue: Int32

        /// All known alternative symlinks I/O policies.
        public static let allCases: [Self] = [.disabled, .enabled]

        /// Disables alternative symlinks.
        public static let disabled = Self(
            name: "disabled", rawValue: IOPOL_VFS_ALTLINK_DISABLED
        )

        /// Enables alternative symlinks.
        public static let enabled = Self(
            name: "enabled", rawValue: IOPOL_VFS_ALTLINK_ENABLED
        )
    }

    /// Gets the alternative symlinks I/O policy for a given scope.
    public static func getAlternativeSymlinksIOPolicy(
        forScope scope: IOPolicyScope
    ) throws -> AlternativeSymlinksIOPolicy {
        let rawValue = try getIOPolicy(forType: .alternativeSymlinks, andScope: scope)
        return AlternativeSymlinksIOPolicy(name: nil, rawValue: rawValue)
    }

    /// Sets the alternative symlinks I/O policy for a given scope to a given value.
    public static func setAlternativeSymlinksIOPolicy(
        forScope scope: IOPolicyScope, to value: AlternativeSymlinksIOPolicy
    ) throws {
        try setIOPolicy(forType: .alternativeSymlinks, andScope: scope, to: value.rawValue)
    }

    /// MARK: - Block-Size No-Cache Writes

    /// An I/O policy for block-size no-cache writes.
    public struct BlockSizeNoCacheWritesIOPolicy: KassHelpers.NamedOptionEnum {
        /// The name of the policy, if it can be determined.
        public var name: String?

        /// Represents a block-size no-cache writes I/O policy value with an optional name.
        public init(name: String?, rawValue: Int32) {
            self.name = name
            self.rawValue = rawValue
        }

        /// The raw value of the policy.
        public let rawValue: Int32

        /// All known block-size no-cache writes I/O policies.
        public static let allCases: [Self] = [.default, .on]

        /// The default block-size no-cache writes I/O policy.
        public static let `default` = Self(
            name: "default", rawValue: IOPOL_VFS_NOCACHE_WRITE_FS_BLKSIZE_DEFAULT
        )

        /// Enables block-size no-cache writes.
        public static let on = Self(
            name: "on", rawValue: IOPOL_VFS_NOCACHE_WRITE_FS_BLKSIZE_ON
        )
    }

    /// Gets the block-size no-cache writes I/O policy for a given scope.
    public static func getBlockSizeNoCacheWritesIOPolicy(
        forScope scope: IOPolicyScope
    ) throws -> BlockSizeNoCacheWritesIOPolicy {
        let rawValue = try getIOPolicy(forType: .blockSizeNoCacheWrites, andScope: scope)
        return BlockSizeNoCacheWritesIOPolicy(name: nil, rawValue: rawValue)
    }

    /// Sets the block-size no-cache writes I/O policy for a given scope to a given value.
    public static func setBlockSizeNoCacheWritesIOPolicy(
        forScope scope: IOPolicyScope, to value: BlockSizeNoCacheWritesIOPolicy
    ) throws {
        try setIOPolicy(forType: .blockSizeNoCacheWrites, andScope: scope, to: value.rawValue)
    }
}
