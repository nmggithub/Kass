import KassC.CSR
import KassHelpers

extension BSD {
    /// Configuration options for Configurable Security Restrictions (CSR).
    /// - Important: CSR is the system behind the more-commonly-known System Integrity Protection (SIP).
    public struct CSRConfigOptions: OptionSet, Sendable, KassHelpers.NamedOptionEnum {
        /// The name of the CSR configuration, if it can be determined.
        public let name: String?

        /// Represents a CSR configuration with an optional name.
        public init(name: String?, rawValue: csr_config_t) {
            self.name = name
            self.rawValue = rawValue
        }

        /// The raw value of the CSR configuration.
        public let rawValue: csr_config_t

        /// The individual options in the configuration.
        public var options: [Self] { Self.allCases.filter { contains($0) } }

        /// All known options.
        public static let allCases: [Self] = [
            .allowUnrestrictedFS,
            .allowTaskForPID,
            .allowKernelDebugger,
            .allowAppleInternal,
            .allowUnrestrictedDTrace,
            .allowUnrestrictedNVRAM,
            .allowDeviceConfiguration,
            .allowAnyRecoveryOS,
            .allowUnapprovedKexts,
            .allowExecutablePolicyOverride,
            .allowUnauthenticatedRoot,
        ]

        public static let allowUntrustedKexts = Self(
            name: "allowUntrustedKexts",
            rawValue: csr_config_t(CSR_ALLOW_UNTRUSTED_KEXTS)
        )

        public static let allowUnrestrictedFS = Self(
            name: "allowUnrestrictedFS",
            rawValue: csr_config_t(CSR_ALLOW_UNRESTRICTED_FS)
        )

        public static let allowTaskForPID = Self(
            name: "allowTaskForPID",
            rawValue: csr_config_t(CSR_ALLOW_TASK_FOR_PID)
        )

        public static let allowKernelDebugger = Self(
            name: "allowKernelDebugger",
            rawValue: csr_config_t(CSR_ALLOW_KERNEL_DEBUGGER)
        )

        public static let allowAppleInternal = Self(
            name: "allowAppleInternal",
            rawValue: csr_config_t(CSR_ALLOW_APPLE_INTERNAL)
        )

        public static let allowUnrestrictedDTrace = Self(
            name: "allowUnrestrictedDTrace",
            rawValue: csr_config_t(CSR_ALLOW_UNRESTRICTED_DTRACE)
        )

        public static let allowUnrestrictedNVRAM = Self(
            name: "allowUnrestrictedNVRAM",
            rawValue: csr_config_t(CSR_ALLOW_UNRESTRICTED_NVRAM)
        )

        public static let allowDeviceConfiguration = Self(
            name: "allowDeviceConfiguration",
            rawValue: csr_config_t(CSR_ALLOW_DEVICE_CONFIGURATION)
        )

        public static let allowAnyRecoveryOS = Self(
            name: "allowAnyRecoveryOS",
            rawValue: csr_config_t(CSR_ALLOW_ANY_RECOVERY_OS)
        )

        public static let allowUnapprovedKexts = Self(
            name: "allowUnapprovedKexts",
            rawValue: csr_config_t(CSR_ALLOW_UNAPPROVED_KEXTS)
        )

        public static let allowExecutablePolicyOverride = Self(
            name: "allowExecutablePolicyOverride",
            rawValue: csr_config_t(CSR_ALLOW_EXECUTABLE_POLICY_OVERRIDE)
        )

        public static let allowUnauthenticatedRoot = Self(
            name: "allowUnauthenticatedRoot",
            rawValue: csr_config_t(CSR_ALLOW_UNAUTHENTICATED_ROOT)
        )
    }

    /// Checks if the system is configured with the specified CSR options.
    /// - Warning: This function will throw an EPERM error if any of the specified options are not configured.
    public static func csrCheck(_ options: CSRConfigOptions) throws {
        try BSD.call(csr_check(options.rawValue))
    }

    /// The active configuration for Configurable Security Restrictions (CSR).
    public static var activeCSRConfig: CSRConfigOptions {
        get throws {
            var flags: csr_config_t = 0
            try BSD.call(csr_get_active_config(&flags))
            return CSRConfigOptions(rawValue: flags)
        }
    }
}
