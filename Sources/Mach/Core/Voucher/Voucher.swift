import Darwin.Mach.mach_voucher_types
import Foundation

extension Mach {
    // MARK: - Attribute Key
    /// A voucher attribute key.
    public struct VoucherAttributeKey: Mach.NamedOptionEnum {
        /// The name of the key, if it can be determined.
        public var name: String?

        /// Represents a voucher attribute key with an optional name.
        public init(name: String?, rawValue: mach_voucher_attr_key_t) {
            self.name = name
            self.rawValue = rawValue
        }

        /// The raw value of the key.
        public let rawValue: mach_voucher_attr_key_t

        /// All known voucher attribute keys.
        public static let allCases: [Self] = [
            .all, .none, .atm, .importance, .bank, .pthreadPriority, .userData, .test,
        ]

        public static let all = VoucherAttributeKey(
            name: "all", rawValue: ~0  // This should be MACH_VOUCHER_ATTR_KEY_ALL, but it's not bridged correctly.
        )

        public static let none = VoucherAttributeKey(
            name: "none", rawValue: MACH_VOUCHER_ATTR_KEY_NONE
        )

        public static let atm = VoucherAttributeKey(
            name: "atm", rawValue: MACH_VOUCHER_ATTR_KEY_ATM
        )

        public static let importance = VoucherAttributeKey(
            name: "importance", rawValue: MACH_VOUCHER_ATTR_KEY_IMPORTANCE
        )

        public static let bank = VoucherAttributeKey(
            name: "bank", rawValue: MACH_VOUCHER_ATTR_KEY_BANK
        )

        public static let pthreadPriority = VoucherAttributeKey(
            name: "pthpriority", rawValue: MACH_VOUCHER_ATTR_KEY_PTHPRIORITY
        )

        public static let userData = VoucherAttributeKey(
            name: "userData", rawValue: MACH_VOUCHER_ATTR_KEY_USER_DATA
        )

        public static let test = VoucherAttributeKey(
            name: "test", rawValue: MACH_VOUCHER_ATTR_KEY_TEST
        )
    }

    // MARK: - Attribute Command
    /// A voucher attribute command.
    public protocol VoucherAttributeCommand: Mach.NamedOptionEnum
    where RawValue == mach_voucher_attr_command_t {}

    // MARK: - Bank Action
    /// A voucher attribute command for the .bank key.
    public struct BankAction: VoucherAttributeCommand {
        /// The name of the bank action, if it can be determined.
        public var name: String?

        /// Represents a bank action with an optional name.
        public init(name: String?, rawValue: bank_action_t) {
            self.name = name
            self.rawValue = rawValue
        }

        /// The raw value of the back action.
        public let rawValue: bank_action_t

        /// All known bank actions.
        public static let allCases: [Self] = [
            .originatorPid, .personaToken, .personaId, .personaAdoptAny, .originatorProximatePid,
        ]

        public static let originatorPid = Self(
            name: "originatorPid", rawValue: bank_action_t(BANK_ORIGINATOR_PID)
        )

        public static let personaToken = Self(
            name: "personaToken", rawValue: bank_action_t(BANK_PERSONA_TOKEN)
        )

        public static let personaId = Self(
            name: "personaId", rawValue: bank_action_t(BANK_PERSONA_ID)
        )

        public static let personaAdoptAny = Self(
            name: "personaAdoptAny", rawValue: bank_action_t(BANK_PERSONA_ADOPT_ANY)
        )

        public static let originatorProximatePid = Self(
            name: "originatorProximatePid", rawValue: bank_action_t(BANK_ORIGINATOR_PROXIMATE_PID)
        )
    }

    // MARK: - Importance Action
    /// A voucher attribute command for the .importance key.
    public struct ImportanceAction: VoucherAttributeCommand {
        /// The name of the importance action, if it can be determined.
        public var name: String?

        /// Represents an importance action with an optional name.
        public init(name: String?, rawValue: mach_voucher_attr_importance_refs) {
            self.name = name
            self.rawValue = rawValue
        }

        /// The raw value of the importance action.
        public let rawValue: mach_voucher_attr_importance_refs

        /// All known importance actions.
        public static let allCases: [Self] = [
            .addExternal, .dropExternal,
        ]

        public static let addExternal = Self(
            name: "addExternal",
            rawValue: mach_voucher_attr_importance_refs(
                MACH_VOUCHER_IMPORTANCE_ATTR_ADD_EXTERNAL
            )
        )

        public static let dropExternal = Self(
            name: "dropExternal",
            rawValue: mach_voucher_attr_importance_refs(
                MACH_VOUCHER_IMPORTANCE_ATTR_DROP_EXTERNAL
            )
        )
    }

    // MARK: - Voucher
    /// A voucher.
    public class Voucher: Mach.Port {
        public class override var Nil: Self {
            Self(named: IPC_VOUCHER_NULL)
        }
        /// Invokes a command on the voucher.
        public func command(
            key: Mach.VoucherAttributeKey, command: any Mach.VoucherAttributeCommand,
            in: BitwiseCopyable? = nil
        ) throws -> Data? {
            let inContent = `in` != nil ? withUnsafeBytes(of: `in`, { Data(copy $0) }) : Data()
            let outContentPointer = mach_voucher_attr_content_t.allocate(capacity: 1)
            var outContentSize = mach_voucher_attr_content_size_t.max
            try Mach.call(
                mach_voucher_attr_command(
                    self.name, key.rawValue, command.rawValue,
                    UnsafeMutablePointer(
                        mutating: (inContent as NSData).bytes.assumingMemoryBound(to: UInt8.self)
                    ),
                    mach_voucher_attr_content_size_t(inContent.count),
                    outContentPointer, &outContentSize
                )
            )
            guard outContentSize > 0 else { return nil }
            return Data(
                bytes: outContentPointer, count: Int(outContentSize)
            )
        }
    }
}
