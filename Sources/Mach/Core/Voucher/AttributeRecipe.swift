import Darwin.Mach
import Foundation
import KassC.VoucherExtra
import KassHelpers

extension Mach {
    /// A voucher attribute recipe command.
    public protocol VoucherAttributeRecipeCommand: KassHelpers.NamedOptionEnum
    where RawValue == mach_voucher_attr_recipe_command_t {}

    // MARK: - Base Command
    /// A base voucher attribute recipe command.
    public struct VoucherBaseAttributeRecipeCommand: VoucherAttributeRecipeCommand {
        /// The name of the base command, if it can be determined.
        public let name: String?

        /// Represents a base command with an optional name.
        public init(name: String?, rawValue: mach_voucher_attr_recipe_command_t) {
            self.name = name
            self.rawValue = rawValue
        }

        /// The raw value of the base command.
        public let rawValue: mach_voucher_attr_recipe_command_t

        /// All known base commands.
        public static let allCases: [Self] = [
            .noop, .copy, .remove, .setValueHandle, .autoRedeem, .sendPreprocess,
        ]

        public static let noop = Self(name: "noop", rawValue: MACH_VOUCHER_ATTR_NOOP)

        public static let copy = Self(name: "copy", rawValue: MACH_VOUCHER_ATTR_COPY)

        public static let remove = Self(name: "remove", rawValue: MACH_VOUCHER_ATTR_REMOVE)

        public static let setValueHandle = Self(
            name: "setValueHandle", rawValue: MACH_VOUCHER_ATTR_SET_VALUE_HANDLE
        )

        public static let autoRedeem = Self(
            name: "autoRedeem", rawValue: MACH_VOUCHER_ATTR_AUTO_REDEEM
        )

        public static let sendPreprocess = Self(
            name: "sendPreprocess", rawValue: MACH_VOUCHER_ATTR_SEND_PREPROCESS
        )

        public static let redeem = Self(name: "redeem", rawValue: MACH_VOUCHER_ATTR_REDEEM)
    }

    // MARK: - ATM Command
    /// An ATM voucher attribute recipe command.
    @available(macOS, obsoleted: 11.0.1)
    public struct VoucherATMAttributeRecipeCommand: VoucherAttributeRecipeCommand {
        /// The name of the ATM command, if it can be determined.
        public let name: String?

        /// Represents an ATM command with an optional name.
        public init(name: String?, rawValue: mach_voucher_attr_recipe_command_t) {
            self.name = name
            self.rawValue = rawValue
        }

        /// The raw value of the ATM command.
        public let rawValue: mach_voucher_attr_recipe_command_t

        /// All known ATM commands.
        public static let allCases: [Self] = [
            .null, .create, .register,
        ]

        public static let null = Self(
            name: "null", rawValue: MACH_VOUCHER_ATTR_ATM_NULL
        )

        public static let create = Self(
            name: "create", rawValue: MACH_VOUCHER_ATTR_ATM_CREATE
        )

        public static let register = Self(
            name: "register", rawValue: MACH_VOUCHER_ATTR_ATM_REGISTER
        )
    }

    // MARK: - Importance Command
    /// An importance voucher attribute recipe command.
    public struct VoucherImportanceAttributeRecipeCommand: VoucherAttributeRecipeCommand {
        /// The name of the importance command, if it can be determined.
        public let name: String?

        /// Represents an importance command with an optional name.
        public init(name: String?, rawValue: mach_voucher_attr_recipe_command_t) {
            self.name = name
            self.rawValue = rawValue
        }

        /// The raw value of the importance command.
        public let rawValue: mach_voucher_attr_recipe_command_t

        /// All known importance commands.
        public static let allCases: [Self] = [.importanceSelf]

        public static let importanceSelf = Self(
            name: "self", rawValue: MACH_VOUCHER_ATTR_IMPORTANCE_SELF
        )
    }

    // MARK: - Bank Command
    /// A bank voucher attribute recipe command.
    public struct VoucherBankAttributeRecipeCommand: VoucherAttributeRecipeCommand {
        /// The name of the bank command, if it can be determined.
        public let name: String?

        /// Represents a bank command with an optional name.
        public init(name: String?, rawValue: mach_voucher_attr_recipe_command_t) {
            self.name = name
            self.rawValue = rawValue
        }

        /// The raw value of the bank command.
        public let rawValue: mach_voucher_attr_recipe_command_t

        /// All known bank commands.
        public static let allCases: [Self] = [
            .null, .create, .modifyPersona,
        ]

        public static let null = Self(
            name: "null", rawValue: MACH_VOUCHER_ATTR_BANK_NULL
        )

        public static let create = Self(
            name: "create", rawValue: MACH_VOUCHER_ATTR_BANK_CREATE
        )

        public static let modifyPersona = Self(
            name: "modifyPersona", rawValue: MACH_VOUCHER_ATTR_BANK_MODIFY_PERSONA
        )
    }

    // MARK: - POSIX Thread Priority Command
    /// A POSIX thread priority voucher attribute recipe command.
    public struct VoucherPthreadPriorityAttributeRecipeCommand: VoucherAttributeRecipeCommand {
        /// The name of the POSIX thread priority command, if it can be determined.
        public let name: String?

        /// Represents a POSIX thread priority command with an optional name.
        public init(name: String?, rawValue: mach_voucher_attr_recipe_command_t) {
            self.name = name
            self.rawValue = rawValue
        }

        /// The raw value of the POSIX thread priority command.
        public let rawValue: mach_voucher_attr_recipe_command_t

        /// All known POSIX thread priority commands.
        public static let allCases: [Self] = [
            .null, .create,
        ]

        public static let null = Self(
            name: "null", rawValue: MACH_VOUCHER_ATTR_PTHPRIORITY_NULL
        )

        public static let create = Self(
            name: "create", rawValue: MACH_VOUCHER_ATTR_PTHPRIORITY_CREATE
        )
    }

    // MARK: User Data Command
    /// A user data voucher attribute recipe command.
    @available(macOS, deprecated: 13.0)
    public struct VoucherUserDataAttributeRecipeCommand: VoucherAttributeRecipeCommand {
        /// The name of the user data command, if it can be determined.
        public let name: String?

        /// Represents a user data command with an optional name.
        public init(name: String?, rawValue: mach_voucher_attr_recipe_command_t) {
            self.name = name
            self.rawValue = rawValue
        }

        /// The raw value of the user data command.
        public let rawValue: mach_voucher_attr_recipe_command_t

        /// All known user data commands.
        public static let allCases: [Self] = [.store]

        public static let store = Self(
            name: "store", rawValue: MACH_VOUCHER_ATTR_USER_DATA_STORE
        )
    }

    // MARK: - Other Command
    /// A voucher attribute recipe command that cannot be represented by a known command.
    public struct VoucherOtherAttributeRecipeCommand: VoucherAttributeRecipeCommand {
        /// The name of the command, if it can be determined.
        public let name: String?

        /// Represents a command with an optional name.
        public init(name: String?, rawValue: mach_voucher_attr_recipe_command_t) {
            self.name = name
            self.rawValue = rawValue
        }

        /// The raw value of the command.
        public let rawValue: mach_voucher_attr_recipe_command_t

        /// All known other commands.
        public static let allCases: [Self] = []
    }
    // MARK: - Attribute Recipe
    /// A voucher attribute recipe.
    public struct VoucherAttributeRecipe: RawRepresentable {
        /// The raw recipe pointer.
        public var rawValue: mach_voucher_attr_raw_recipe_t

        /// The typed recipe pointer.
        public var typedValue: mach_voucher_attr_recipe_t {
            self.rawValue.withMemoryRebound(
                to: mach_voucher_attr_recipe_data_t.self, capacity: 1
            ) { $0 }
        }

        /// Represents an existing voucher attribute recipe.
        public init(rawValue: mach_voucher_attr_raw_recipe_t) { self.rawValue = rawValue }

        /// Creates a new voucher attribute recipe.
        public init(
            key: Mach.VoucherAttributeKey, command: some Mach.VoucherAttributeRecipeCommand,
            previousVoucher: Mach.Voucher = Mach.Voucher.Nil, content: Data? = nil
        ) {
            let contentSize = mach_voucher_attr_content_size_t(content?.count ?? 0)
            let totalSize = MemoryLayout<mach_voucher_attr_recipe_data_t>.size + Int(contentSize)
            let recipePointer = UnsafeMutablePointer<UInt8>.allocate(capacity: totalSize)
            recipePointer.withMemoryRebound(
                to: mach_voucher_attr_recipe_data_t.self, capacity: 1
            ) {
                $0.pointee.key = key.rawValue
                $0.pointee.command = command.rawValue
                $0.pointee.previous_voucher = previousVoucher.name
                $0.pointee.content_size = contentSize
            }
            if let inputContent = content {
                inputContent.withUnsafeBytes { (inputContentBytes: UnsafeRawBufferPointer) in
                    let selfContentBuffer = UnsafeMutableBufferPointer<UInt8>(
                        start: recipePointer.advanced(
                            by: MemoryLayout<mach_voucher_attr_recipe_data_t>.size
                        ), count: inputContent.count
                    )
                    inputContentBytes.copyBytes(to: selfContentBuffer, count: inputContent.count)
                }
            }
            self.rawValue = recipePointer
        }

        /// Creates a new voucher attribute recipe for an importance command.
        public init(
            importanceCommand: Mach.VoucherImportanceAttributeRecipeCommand,
            previousVoucher: Mach.Voucher = Mach.Voucher.Nil, content: Data? = nil
        ) {
            self.init(
                key: .importance, command: importanceCommand,
                previousVoucher: previousVoucher, content: content
            )
        }

        /// Creates a new voucher attribute recipe for an ATM command.
        public init(
            atmCommand: Mach.VoucherATMAttributeRecipeCommand,
            previousVoucher: Mach.Voucher = Mach.Voucher.Nil, content: Data? = nil
        ) {
            self.init(
                key: .atm, command: atmCommand,
                previousVoucher: previousVoucher, content: content
            )
        }

        /// Creates a new voucher attribute recipe for a bank command.
        public init(
            bankCommand: Mach.VoucherBankAttributeRecipeCommand,
            previousVoucher: Mach.Voucher = Mach.Voucher.Nil, content: Data? = nil
        ) {
            self.init(
                key: .bank, command: bankCommand,
                previousVoucher: previousVoucher, content: content
            )
        }

        /// Creates a new voucher attribute recipe for a POSIX thread priority command.
        public init(
            pthreadPriorityCommand: Mach.VoucherPthreadPriorityAttributeRecipeCommand,
            previousVoucher: Mach.Voucher = Mach.Voucher.Nil, content: Data? = nil
        ) {
            self.init(
                key: .pthreadPriority, command: pthreadPriorityCommand,
                previousVoucher: previousVoucher, content: content
            )
        }

        /// Creates a new voucher attribute recipe for a user data command.
        public init(
            userDataCommand: Mach.VoucherUserDataAttributeRecipeCommand,
            previousVoucher: Mach.Voucher = Mach.Voucher.Nil, content: Data? = nil
        ) {
            self.init(
                key: .userData, command: userDataCommand,
                previousVoucher: previousVoucher, content: content
            )
        }

        /// The key for the recipe.
        public var key: Mach.VoucherAttributeKey {
            Mach.VoucherAttributeKey(rawValue: self.typedValue.pointee.key)
        }

        /// The command in the recipe.
        public var command: any Mach.VoucherAttributeRecipeCommand {
            for commandType: any Mach.VoucherAttributeRecipeCommand.Type in [
                Mach.VoucherBaseAttributeRecipeCommand.self,
                Mach.VoucherImportanceAttributeRecipeCommand.self,
                Mach.VoucherATMAttributeRecipeCommand.self,
                Mach.VoucherBankAttributeRecipeCommand.self,
                Mach.VoucherPthreadPriorityAttributeRecipeCommand.self,
            ] {
                let command = commandType.init(rawValue: self.typedValue.pointee.command)
                // Known commands should have a name, so we can use the existence of
                // a name as a proxy for whether the command is known or not.
                if command.name != nil { return command }
            }
            return Mach.VoucherOtherAttributeRecipeCommand(
                name: nil, rawValue: self.typedValue.pointee.command
            )
        }

        /// The previous voucher in the recipe.
        public var previousVoucher: Mach.Voucher {
            Mach.Voucher(named: self.typedValue.pointee.previous_voucher)
        }

        /// The advertised size of the additional content in the recipe.
        public var contentSize: mach_voucher_attr_content_size_t {
            self.typedValue.pointee.content_size
        }

        /// The additional content in the recipe.
        public var content: Data {
            Data(
                bytes: UnsafeRawPointer(self.typedValue).advanced(
                    by: MemoryLayout<mach_voucher_attr_recipe_data_t>.size),
                count: Int(self.contentSize)
            )
        }

        /// The total size of the recipe.
        public var size: Int {
            MemoryLayout<mach_voucher_attr_recipe_data_t>.size + Int(self.contentSize)
        }
    }
}

// MARK: - Voucher Extensions
extension Mach.Voucher {
    /// Creates a new voucher with the given recipes.
    public convenience init(recipes: consuming [Mach.VoucherAttributeRecipe]) throws {
        let totalSize = recipes.reduce(0, { $0 + $1.size })
        let recipeArray = mach_voucher_attr_raw_recipe_array_t.allocate(capacity: totalSize)
        var currentPointer = recipeArray
        for recipe in recipes {
            let recipeSize = recipe.size
            UnsafeMutableRawPointer(currentPointer).copyMemory(
                from: UnsafeRawPointer(recipe.rawValue), byteCount: recipeSize
            )
            currentPointer = currentPointer.advanced(by: recipeSize)
        }
        var voucherName: mach_voucher_name_t = MACH_VOUCHER_NAME_NULL
        try Mach.call(
            host_create_mach_voucher(
                Mach.Host.current.name, recipeArray,
                mach_msg_type_number_t(totalSize),
                &voucherName
            )
        )
        self.init(named: voucherName)
    }

    /// Gets a recipe from the voucher.
    /// - Warning: This function allocates memory for the recipe. Deallocation is the responsibility of the caller.
    public func recipe(forKey key: Mach.VoucherAttributeKey) throws -> mach_voucher_attr_recipe_t {
        // The kernel will return an error if the size is too large, so we use the maximum allowed size. It's a bit of a
        // mystery as to why the kernel checks the size against a macro called MAX_RAW_RECIPE_ARRAY_SIZE when we're only
        // extracting one recipe (not an array), but we have to work with it.
        var size = mach_voucher_attr_raw_recipe_size_t(MACH_VOUCHER_ATTR_MAX_RAW_RECIPE_ARRAY_SIZE)
        let rawRecipe = mach_voucher_attr_raw_recipe_t.allocate(capacity: Int(size))
        defer { rawRecipe.deallocate() }
        try Mach.call(mach_voucher_extract_attr_recipe(self.name, key.rawValue, rawRecipe, &size))
        return rawRecipe.withMemoryRebound(to: mach_voucher_attr_recipe_data_t.self, capacity: 1) {
            $0
        }
    }

    /// The recipes in the voucher.
    /// - Warning: This property accessor allocates memory for the recipes. Deallocation is the responsibility of the caller.
    public var recipes: [Mach.VoucherAttributeRecipe] {
        get throws {
            // We need to make sure we allocate enough memory to store all the recipes. The kernel
            // will return an error if the size is too small, so we use the maximum size.
            var size = mach_voucher_attr_raw_recipe_size_t(
                MACH_VOUCHER_ATTR_MAX_RAW_RECIPE_ARRAY_SIZE
            )
            let rawArray = mach_voucher_attr_raw_recipe_array_t.allocate(
                capacity: Int(size)
            )
            try Mach.call(mach_voucher_extract_all_attr_recipes(self.name, rawArray, &size))
            var recipes: [Mach.VoucherAttributeRecipe] = []
            var sizeRemaining = size
            var rawRecipePointer = rawArray
            while sizeRemaining > 0 {
                let recipeToAppend = Mach.VoucherAttributeRecipe(rawValue: rawRecipePointer)
                recipes.append(recipeToAppend)
                let recipeSize = mach_voucher_attr_raw_recipe_size_t(
                    MemoryLayout<mach_voucher_attr_recipe_data_t>.size
                        + recipeToAppend.content.count
                )
                sizeRemaining -= recipeSize
                rawRecipePointer = rawRecipePointer.advanced(by: Int(recipeSize))
            }
            return recipes
        }
    }
}
