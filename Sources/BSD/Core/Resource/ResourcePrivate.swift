import KassC.ResourcePrivate
import KassHelpers

/// Private target types.
extension BSD.PriorityTargetType {
    /// Targets the GPU priority for a process.
    internal static let gpuForProcess = Self(name: "gpuForProcess", rawValue: PRIO_DARWIN_GPU)

    /// Targets the role for a process.
    internal static let roleForProcess = Self(name: "roleForProcess", rawValue: PRIO_DARWIN_ROLE)

    /// Targets the game mode for a process.
    internal static let gameModeForProcess = Self(
        name: "gameModeForProcess", rawValue: PRIO_DARWIN_GAME_MODE
    )

    /// Targets the CarPlay mode for a process.
    internal static let carPlayModeForProcess = Self(
        name: "carPlayModeForProcess", rawValue: PRIO_DARWIN_CARPLAY_MODE
    )
}

extension BSD {
    // MARK: - GPU

    /// A GPU priority for a process.
    public struct GPUPriority: KassHelpers.NamedOptionEnum {
        /// The name of the priority, if it can be determined.
        public var name: String?

        /// Represents a GPU priority with an optional name.
        public init(name: String?, rawValue: Int32) {
            self.name = name
            self.rawValue = rawValue
        }

        /// The raw value of the priority.
        public let rawValue: Int32

        /// All known GPU priorities.
        public static let allCases: [Self] = []

        /// Allows the process to use the GPU.
        public static let allow = Self(name: "allow", rawValue: PRIO_DARWIN_GPU_ALLOW)

        /// Denies the process from using the GPU.
        public static let deny = Self(name: "deny", rawValue: PRIO_DARWIN_GPU_DENY)
    }

    /// Gets the GPU priority of a process with a given ID.
    public static func getGPUPriority(forPID pid: pid_t) throws -> GPUPriority {
        return GPUPriority(rawValue: try self.getPriority(for: .gpuForProcess, withID: id_t(pid)))
    }

    /// Sets the GPU priority of a process with a given ID to a given value.
    public static func setGPUPriority(forPID pid: pid_t, to priority: GPUPriority) throws {
        try self.setPriority(for: .gpuForProcess, withID: id_t(pid), to: priority.rawValue)
    }

    // MARK: - Role

    /// A Darwin role for a process.
    public struct DarwinRole: KassHelpers.NamedOptionEnum {
        /// The name of the role, if it can be determined.
        public var name: String?

        /// Represents a Darwin role with an optional name.
        public init(name: String?, rawValue: Int32) {
            self.name = name
            self.rawValue = rawValue
        }

        /// The raw value of the role.
        public let rawValue: Int32

        /// All known Darwin roles.
        public static let allCases: [Self] = [
            .default,
            .uiFocal,
            .ui,
            .nonUI,
            .uiNonFocal,
            .transparentAppLifecycleLaunch,
            .darwinBackground,
        ]

        /// The default role for a process.
        public static let `default` = Self(
            name: "default", rawValue: PRIO_DARWIN_ROLE_DEFAULT
        )

        /// An on-screen and focused process.
        public static let uiFocal = Self(
            name: "uiFocal", rawValue: PRIO_DARWIN_ROLE_UI_FOCAL
        )

        /// An on-screen process with an unknown focus state.
        public static let ui = Self(
            name: "ui", rawValue: PRIO_DARWIN_ROLE_UI
        )

        /// An off-screen unfocused process.
        public static let nonUI = Self(
            name: "nonUI", rawValue: PRIO_DARWIN_ROLE_NON_UI
        )

        /// An off-screen and unfocused process.
        public static let uiNonFocal = Self(
            name: "uiNonFocal", rawValue: PRIO_DARWIN_ROLE_UI_NON_FOCAL
        )

        /// A process launched through Transparent App Lifecycle (TAL).
        public static let transparentAppLifecycleLaunch = Self(
            name: "transparentAppLifecycleLaunch", rawValue: PRIO_DARWIN_ROLE_TAL_LAUNCH
        )

        /// A Darwin background process.
        public static let darwinBackground = Self(
            name: "background", rawValue: PRIO_DARWIN_ROLE_DARWIN_BG
        )
    }

    /// Gets the Darwin role of a process with a given ID.
    public static func getDarwinRole(forPID pid: pid_t) throws -> DarwinRole {
        return DarwinRole(rawValue: try self.getPriority(for: .roleForProcess, withID: id_t(pid)))
    }

    /// Sets the Darwin role of a process with a given ID to a given value.
    public static func setDarwinRole(
        forPID pid: pid_t, to role: DarwinRole
    ) throws {
        try self.setPriority(for: .roleForProcess, withID: id_t(pid), to: role.rawValue)
    }

    // MARK: - Game Mode

    /// A game mode for a process.
    public struct ProcessGameMode: KassHelpers.NamedOptionEnum {
        /// The name of the game mode, if it can be determined.
        public var name: String?

        /// Represents a game mode with an optional name.
        public init(name: String?, rawValue: Int32) {
            self.name = name
            self.rawValue = rawValue
        }

        /// The raw value of the game mode.
        public let rawValue: Int32

        /// All known game modes.
        public static let allCases: [Self] = [.on, .off]

        /// Turns on the game mode for a process.
        public static let on = Self(name: "on", rawValue: PRIO_DARWIN_GAME_MODE_OFF)

        /// Turns off the game mode for a process.
        public static let off = Self(name: "off", rawValue: PRIO_DARWIN_GAME_MODE_ON)
    }

    /// Gets the game mode of a process with a given ID.
    public static func getGameMode(forPID pid: pid_t) throws -> ProcessGameMode {
        return ProcessGameMode(
            rawValue: try self.getPriority(for: .gameModeForProcess, withID: id_t(pid))
        )
    }

    /// Sets the game mode of a process with a given ID to a given value.
    public static func setGameMode(
        forPID pid: pid_t, to gameMode: ProcessGameMode
    ) throws {
        try self.setPriority(for: .gameModeForProcess, withID: id_t(pid), to: gameMode.rawValue)
    }

    // MARK: - CarPlay Mode

    /// A CarPlay mode for a process.
    public struct ProcessCarPlayMode: KassHelpers.NamedOptionEnum {
        /// The name of the CarPlay mode, if it can be determined.
        public var name: String?

        /// Represents a CarPlay mode with an optional name.
        public init(name: String?, rawValue: Int32) {
            self.name = name
            self.rawValue = rawValue
        }

        /// The raw value of the CarPlay mode.
        public let rawValue: Int32

        /// All known CarPlay modes.
        public static let allCases: [Self] = [.on, .off]

        /// Turns on the CarPlay mode for a process.
        public static let on = Self(name: "on", rawValue: PRIO_DARWIN_CARPLAY_MODE_OFF)

        /// Turns off the CarPlay mode for a process.
        public static let off = Self(name: "off", rawValue: PRIO_DARWIN_CARPLAY_MODE_ON)
    }

    /// Gets the CarPlay mode of a process with a given ID.
    public static func getCarPlayMode(forPID pid: pid_t) throws -> ProcessCarPlayMode {
        return ProcessCarPlayMode(
            rawValue: try self.getPriority(for: .carPlayModeForProcess, withID: id_t(pid))
        )
    }

    /// Sets the CarPlay mode of a process with a given ID to a given value.
    public static func setCarPlayMode(
        forPID pid: pid_t, to carPlayMode: ProcessCarPlayMode
    ) throws {
        try self.setPriority(
            for: .carPlayModeForProcess, withID: id_t(pid), to: carPlayMode.rawValue
        )
    }
}
