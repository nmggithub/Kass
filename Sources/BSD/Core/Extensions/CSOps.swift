import Darwin.POSIX
import Foundation
import KassC.CSBlobs
import KassC.CodeSign
import KassHelpers

extension BSD {
    // A code signing attribute (or flag) for a process.
    public struct CSFlags: OptionSet, KassHelpers.NamedOptionEnum {
        /// The name of the flag, if it can be determined.
        public var name: String?

        /// Represents a code signing flag with an optional name.
        public init(name: String?, rawValue: UInt32) {
            self.name = name
            self.rawValue = rawValue
        }

        /// The raw value of the flag.
        public let rawValue: UInt32

        /// The individual flags in the collection.
        public var flags: [Self] { Self.allCases.filter { self.contains($0) } }

        /// All known code signing flags.
        public static let allCases: [Self] = [
            .valid, .adhoc, .getTaskAllow, .installer, .forcedLibraryValidation, .invalidAllowed,
            .hard, .kill, .checkExpiration, .restrict, .enforcement, .requireLibraryValidation,
            .entitlementsValidated, .nvramUnrestricted, .runtime, .linkerSigned, .execSetHard,
            .execSetKill, .execSetEnforcement, .execInheritSIP, .killed, .noUntrustedHelpers,
            .platformBinary, .platformPath, .debugged, .signed, .devCode, .dataVaultController,
        ]

        public static let valid = Self(name: "valid", rawValue: UInt32(CS_VALID))

        public static let adhoc = Self(name: "adhoc", rawValue: UInt32(CS_ADHOC))

        public static let getTaskAllow = Self(
            name: "getTaskAllow", rawValue: UInt32(CS_GET_TASK_ALLOW)
        )

        public static let installer = Self(name: "installer", rawValue: UInt32(CS_INSTALLER))

        public static let forcedLibraryValidation = Self(
            name: "forcedLibraryValidation", rawValue: UInt32(CS_FORCED_LV)
        )

        public static let invalidAllowed = Self(
            name: "invalidAllowed", rawValue: UInt32(CS_INVALID_ALLOWED)
        )

        public static let hard = Self(name: "hard", rawValue: UInt32(CS_HARD))

        public static let kill = Self(name: "kill", rawValue: UInt32(CS_KILL))

        public static let checkExpiration = Self(
            name: "checkExpiration", rawValue: UInt32(CS_CHECK_EXPIRATION)
        )

        public static let restrict = Self(name: "restrict", rawValue: UInt32(CS_RESTRICT))

        public static let enforcement = Self(name: "enforcement", rawValue: UInt32(CS_ENFORCEMENT))

        public static let requireLibraryValidation = Self(
            name: "requireLibraryValidation", rawValue: UInt32(CS_REQUIRE_LV)
        )

        public static let entitlementsValidated = Self(
            name: "entitlementsValidated", rawValue: UInt32(CS_ENTITLEMENTS_VALIDATED)
        )

        public static let nvramUnrestricted = Self(
            name: "nvramUnrestricted", rawValue: UInt32(CS_NVRAM_UNRESTRICTED)
        )

        public static let runtime = Self(name: "runtime", rawValue: UInt32(CS_RUNTIME))

        public static let linkerSigned = Self(
            name: "linkerSigned", rawValue: UInt32(CS_LINKER_SIGNED)
        )

        public static let execSetHard = Self(
            name: "execSetHard", rawValue: UInt32(CS_EXEC_SET_HARD)
        )

        public static let execSetKill = Self(
            name: "execSetKill", rawValue: UInt32(CS_EXEC_SET_KILL)
        )

        public static let execSetEnforcement = Self(
            name: "execSetEnforcement", rawValue: UInt32(CS_EXEC_SET_ENFORCEMENT)
        )

        public static let execInheritSIP = Self(
            name: "execInheritSIP", rawValue: UInt32(CS_EXEC_INHERIT_SIP)
        )

        public static let killed = Self(name: "killed", rawValue: UInt32(CS_KILLED))

        public static let noUntrustedHelpers = Self(
            name: "noUntrustedHelpers", rawValue: UInt32(CS_NO_UNTRUSTED_HELPERS)
        )

        @available(macOS, deprecated: 12.0.1, message: "Use `noUntrustedHelpers` instead.")
        public static let dyldPlatform = Self(
            name: "dyldPlatform", rawValue: UInt32(CS_DYLD_PLATFORM)
        )

        public static let platformBinary = Self(
            name: "platformBinary", rawValue: UInt32(CS_PLATFORM_BINARY)
        )

        public static let platformPath = Self(
            name: "platformPath", rawValue: UInt32(CS_PLATFORM_PATH)
        )

        public static let debugged = Self(name: "debugged", rawValue: UInt32(CS_DEBUGGED))

        public static let signed = Self(name: "signed", rawValue: UInt32(CS_SIGNED))

        public static let devCode = Self(name: "devCode", rawValue: UInt32(CS_DEV_CODE))

        public static let dataVaultController = Self(
            name: "dataVaultController", rawValue: UInt32(CS_DATAVAULT_CONTROLLER)
        )
    }

    // A code signing operation.
    public struct CSOperation: KassHelpers.NamedOptionEnum {
        /// The name of the operation, if it can be determined.
        public var name: String?

        /// Represents a code signing operation with an optional name.
        public init(name: String?, rawValue: UInt32) {
            self.name = name
            self.rawValue = rawValue
        }

        /// The raw value of the operation.
        public let rawValue: UInt32

        /// All known code signing operations.
        public static let allCases: [Self] = [
            .getStatus, .markInvalid, .markHard, .markKill, .getCDHash, .getPIDOffset,
            .getEntitlementsBlob, .markRestrict, .setStatus, .getCSBlob, .getIdentity,
            .clearInstallerFlags, .getTeamID, .clearLibraryValidation, .getDEREntitlementsBlob,
            .getValidationCategory,
        ]

        // Get the code signing status.
        public static let getStatus = Self(name: "getStatus", rawValue: UInt32(CS_OPS_STATUS))

        // Mark the process as invalid.
        public static let markInvalid = Self(
            name: "markInvalid", rawValue: UInt32(CS_OPS_MARKINVALID))

        // Set the HARD flag.
        public static let markHard = Self(name: "markHard", rawValue: UInt32(CS_OPS_MARKHARD))

        // Set the KILL flag.
        public static let markKill = Self(name: "markKill", rawValue: UInt32(CS_OPS_MARKKILL))

        // Get the code directory hash.
        public static let getCDHash = Self(name: "getCDHash", rawValue: UInt32(CS_OPS_CDHASH))

        // Get the offset of the active Mach-O slice.
        public static let getPIDOffset = Self(
            name: "getPIDOffset", rawValue: UInt32(CS_OPS_PIDOFFSET))

        // Get the entitlements blob (XML).
        public static let getEntitlementsBlob = Self(
            name: "getEntitlementsBlob", rawValue: UInt32(CS_OPS_ENTITLEMENTS_BLOB)
        )

        // Set the RESTRICT flag.
        public static let markRestrict = Self(
            name: "markRestrict", rawValue: UInt32(CS_OPS_MARKRESTRICT)
        )

        // Set the code signing status.
        public static let setStatus = Self(name: "setStatus", rawValue: UInt32(CS_OPS_SET_STATUS))

        // Get the code signing blob.
        public static let getCSBlob = Self(name: "getCSBlob", rawValue: UInt32(CS_OPS_BLOB))

        // Get the code signing identity.
        public static let getIdentity = Self(name: "getIdentity", rawValue: UInt32(CS_OPS_IDENTITY))

        // Clear the installer-related flags.
        public static let clearInstallerFlags = Self(
            name: "clearInstallerFlags", rawValue: UInt32(CS_OPS_CLEARINSTALLER)
        )

        // Clear the platform-related flags.
        public static let clearPlatformFlags = Self(
            name: "clearPlatformFlags", rawValue: UInt32(CS_OPS_CLEARPLATFORM)
        )

        // Get the team ID.
        public static let getTeamID = Self(name: "getTeamID", rawValue: UInt32(CS_OPS_TEAMID))

        // Clear the library validation flag.
        // - Note: This is currently restricted to the caller's PID, and the caller must have a special entitlement.
        public static let clearLibraryValidation = Self(
            name: "clearLibraryValidation", rawValue: UInt32(CS_OPS_CLEAR_LV)
        )

        // Get the entitlements blob (DER).
        public static let getDEREntitlementsBlob = Self(
            name: "getDEREntitlementsBlob", rawValue: UInt32(CS_OPS_DER_ENTITLEMENTS_BLOB)
        )

        // Get the validation category.
        public static let getValidationCategory = Self(
            name: "getValidationCategory", rawValue: UInt32(CS_OPS_VALIDATION_CATEGORY)
        )
    }

    // A code signing validation category.
    public struct CSValidationCategory: KassHelpers.NamedOptionEnum {
        /// The name of the validation category, if it can be determined.
        public var name: String?

        /// Represents a code signing validation category with an optional name.
        public init(name: String?, rawValue: UInt32) {
            self.name = name
            self.rawValue = rawValue
        }

        /// The raw value of the validation category.
        public let rawValue: UInt32

        /// All known code signing validation categories.
        public static let allCases: [Self] = [
            .invalid, .platform, .testFlight, .development, .appStore,
            .enterprise, .developerID, .localSigning, .rosetta, .OOP_JIT,
            .none,
        ]

        public static let invalid = Self(
            name: "invalid", rawValue: UInt32(CS_VALIDATION_CATEGORY_INVALID)
        )

        public static let platform = Self(
            name: "platform", rawValue: UInt32(CS_VALIDATION_CATEGORY_PLATFORM)
        )

        public static let testFlight = Self(
            name: "testFlight", rawValue: UInt32(CS_VALIDATION_CATEGORY_TESTFLIGHT)
        )

        public static let development = Self(
            name: "development", rawValue: UInt32(CS_VALIDATION_CATEGORY_DEVELOPMENT)
        )

        public static let appStore = Self(
            name: "appStore", rawValue: UInt32(CS_VALIDATION_CATEGORY_APP_STORE)
        )

        public static let enterprise = Self(
            name: "enterprise", rawValue: UInt32(CS_VALIDATION_CATEGORY_ENTERPRISE)
        )

        public static let developerID = Self(
            name: "developerID", rawValue: UInt32(CS_VALIDATION_CATEGORY_DEVELOPER_ID)
        )

        public static let localSigning = Self(
            name: "localSigning", rawValue: UInt32(CS_VALIDATION_CATEGORY_LOCAL_SIGNING)
        )

        public static let rosetta = Self(
            name: "rosetta", rawValue: UInt32(CS_VALIDATION_CATEGORY_ROSETTA)
        )

        public static let OOP_JIT = Self(
            name: "OOP_JIT", rawValue: UInt32(CS_VALIDATION_CATEGORY_OOPJIT)
        )

        public static let none = Self(
            name: "none", rawValue: UInt32(CS_VALIDATION_CATEGORY_NONE)
        )
    }

    public struct CSOps {
        // Perform a code signing operation on a process.
        @discardableResult
        public static func call(
            _ pid: pid_t, _ ops: CSOperation,
            auditToken: audit_token_t? = nil,
            dataIn: Data = Data(),
            // The system call will still copy data when ERANGE is returned, so the user
            // should have the option to ignore an ERANGE error and still get the data.
            ignoreERANGE: Bool = false
        ) throws -> Data {
            var inBytes = [UInt8](dataIn)
            call: do {
                if var token = auditToken {
                    try BSD.syscall(
                        csops_audittoken(pid, ops.rawValue, &inBytes, inBytes.count, &token)
                    )
                } else {
                    try BSD.syscall(csops(pid, ops.rawValue, &inBytes, inBytes.count))
                }
            } catch {
                if let posixError = error as? POSIXError,
                    posixError.code == .ERANGE,
                    ignoreERANGE
                {
                    break call
                }
                throw error
            }
            return Data(bytes: &inBytes, count: inBytes.count)
        }

        public static func getStatus(
            _ pid: pid_t, auditToken: audit_token_t? = nil
        ) throws -> CSFlags {
            try call(
                pid,
                .getStatus,
                auditToken: auditToken,
                dataIn: Data([UInt8](repeating: 0, count: MemoryLayout<UInt32>.size))
            ).withUnsafeBytes { buffer in
                return CSFlags(rawValue: buffer.load(as: UInt32.self))
            }
        }

        public static func markInvalid(_ pid: pid_t, auditToken: audit_token_t? = nil) throws {
            try self.call(pid, .markInvalid, auditToken: auditToken)
        }

        public static func markHard(_ pid: pid_t, auditToken: audit_token_t? = nil) throws {
            try self.call(pid, .markHard, auditToken: auditToken)
        }

        public static func markKill(_ pid: pid_t, auditToken: audit_token_t? = nil) throws {
            try self.call(pid, .markKill, auditToken: auditToken)
        }

        public static func getCDHash(_ pid: pid_t, auditToken: audit_token_t? = nil) throws -> Data
        {
            return try self.call(
                pid, .getCDHash, auditToken: auditToken,
                dataIn: Data([UInt8](repeating: 0, count: Int(CS_SHA1_LEN)))
            )
        }

        public static func getPIDOffset(_ pid: pid_t, auditToken: audit_token_t? = nil) throws
            -> UInt64
        {
            return try self.call(
                pid, .getPIDOffset, auditToken: auditToken,
                dataIn: Data([UInt8](repeating: 0, count: MemoryLayout<UInt64>.size))
            ).withUnsafeBytes { buffer in
                return buffer.load(as: UInt64.self)
            }
        }

        /// The size of the header of a code signing blob.
        private static let blobHeaderSize = MemoryLayout<__SC_GenericBlob>.size

        /// Get a blob through a code signing operation.
        private static func getBlob(
            _ operation: CSOperation,
            _ pid: pid_t, auditToken: audit_token_t? = nil
        ) throws -> Data {
            let firstDataOut = try self.call(
                pid, operation, auditToken: auditToken,
                // Only get the header first.
                dataIn: Data([UInt8](repeating: 0, count: self.blobHeaderSize)),
                // ERANGE is expected here, since we're not getting the full blob.
                ignoreERANGE: true
            )
            let blob = firstDataOut.withUnsafeBytes {
                buffer -> __SC_GenericBlob in
                return buffer.load(as: __SC_GenericBlob.self)
            }
            // The length field is in network byte order.
            let actualLength = blob.length.byteSwapped
            let dataOut = try self.call(
                pid, operation, auditToken: auditToken,
                // Get the full blob.
                dataIn: Data([UInt8](repeating: 0, count: Int(actualLength)))
            )
            return dataOut
        }

        public static func getEntitlementsBlob(
            _ pid: pid_t, auditToken: audit_token_t? = nil
        ) throws -> Data {
            return try self.getBlob(.getEntitlementsBlob, pid, auditToken: auditToken)
        }

        public static func markRestrict(_ pid: pid_t, auditToken: audit_token_t? = nil) throws {
            try self.call(pid, .markRestrict, auditToken: auditToken)
        }

        public static func setStatus(
            _ pid: pid_t, _ flags: CSFlags, auditToken: audit_token_t? = nil
        ) throws {
            var flags = flags.rawValue
            try self.call(
                pid, .setStatus, auditToken: auditToken,
                dataIn: Data(bytes: &flags, count: MemoryLayout<UInt32>.size)
            )
        }

        public static func getCSBlob(_ pid: pid_t, auditToken: audit_token_t? = nil) throws
            -> Data
        {
            try self.getBlob(.getCSBlob, pid, auditToken: auditToken)
        }

        public static func getIdentity(_ pid: pid_t, auditToken: audit_token_t? = nil) throws
            -> String?
        {
            let identityData = try self.getBlob(.getIdentity, pid, auditToken: auditToken)
            return String(data: identityData, encoding: .utf8)
        }

        public static func clearInstallerFlags(_ pid: pid_t, auditToken: audit_token_t? = nil)
            throws
        {
            try self.call(pid, .clearInstallerFlags, auditToken: auditToken)
        }

        public static func clearPlatformFlags(_ pid: pid_t, auditToken: audit_token_t? = nil) throws
        {
            try self.call(pid, .clearLibraryValidation, auditToken: auditToken)
        }

        public static func getTeamID(_ pid: pid_t, auditToken: audit_token_t? = nil) throws
            -> String?
        {
            let teamIDData = try self.getBlob(.getTeamID, pid, auditToken: auditToken)
            return String(data: teamIDData, encoding: .utf8)
        }

        public static func clearLibraryValidation(
            _ pid: pid_t, auditToken: audit_token_t? = nil
        ) throws {
            try self.call(pid, .clearLibraryValidation, auditToken: auditToken)
        }

        public static func getDEREntitlementsBlob(
            _ pid: pid_t, auditToken: audit_token_t? = nil
        ) throws -> Data {
            return try self.getBlob(.getDEREntitlementsBlob, pid, auditToken: auditToken)
        }

        public static func getValidationCategory(
            _ pid: pid_t, auditToken: audit_token_t? = nil
        ) throws -> CSValidationCategory {
            try self.call(
                pid,
                .getValidationCategory,
                auditToken: auditToken,
                dataIn: Data([UInt8](repeating: 0, count: MemoryLayout<UInt32>.size))
            ).withUnsafeBytes { buffer in
                return CSValidationCategory(rawValue: buffer.load(as: UInt32.self))
            }
        }
    }

}