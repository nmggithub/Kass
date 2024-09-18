import Darwin.Mach
import Foundation

extension Mach.Voucher {
    public struct AttributeRecipe {
        /// A recipe command.
        public enum Command: mach_voucher_attr_recipe_command_t {
            case noop = 0
            case copy = 1
            case remove = 2
            case setValueHandle = 3
            case autoRedeem = 4
            case sendPreprocess = 5

            case redeem = 10

            case importanceSelf = 200
            case userDataStore = 211

            case atmNull = 501
            case atmCreate = 502
            case atmRegister = 503

            case bankNull = 601
            case bankCreate = 610
            case bankModifyPersona = 611

            case pthpriorityNull = 701
            case pthpriorityCreate = 702
        }
        /// The raw recipe pointer.
        public let rawValue: mach_voucher_attr_raw_recipe_t
        /// The typed recipe pointer.
        public var typedValue: mach_voucher_attr_recipe_t {
            self.rawValue.withMemoryRebound(
                to: mach_voucher_attr_recipe_data_t.self, capacity: 1
            ) { $0 }
        }
        /// Create a new recipe with the given raw value.
        /// - Parameter rawValue: The raw value to create the recipe with.
        public init(rawValue: mach_voucher_attr_raw_recipe_t) {
            let contentSize = rawValue.withMemoryRebound(
                to: mach_voucher_attr_recipe_data_t.self, capacity: 1, { $0.pointee.content_size }
            )
            let totalSize = MemoryLayout<mach_voucher_attr_recipe_data_t>.size + Int(contentSize)
            // Create a new pointer to store the raw value. We do this because the passed-in pointer
            // might be deallocated beyond our control. We need to manage the memory ourselves.
            let pointer = UnsafeMutablePointer<UInt8>.allocate(capacity: totalSize)
            UnsafeMutableRawPointer(pointer).copyMemory(
                from: rawValue, byteCount: totalSize
            )
            self.rawValue = pointer
        }
        /// The key of the recipe.
        public var key: AttributeKey? {
            AttributeKey(rawValue: self.typedValue.pointee.key)
        }
        /// The command of the recipe.
        public var command: Command? {
            Command(rawValue: self.typedValue.pointee.command)
        }
        /// The previous voucher.
        public var previous: Mach.Voucher? {
            return Mach.Voucher(named: self.typedValue.pointee.previous_voucher)
        }
        /// The content of the recipe.
        public var content: Data {
            Data(
                bytes: UnsafeRawPointer(self.typedValue.advanced(by: 1)),
                count: Int(self.typedValue.pointee.content_size)
            )
        }
        /// The size of the recipe.
        public var size: Int {
            MemoryLayout<mach_voucher_attr_recipe_data_t>.size
                + Int(self.typedValue.pointee.content_size)
        }
    }

    /// Create a new voucher with the given recipes.
    /// - Parameter recipes: The recipes to create the voucher with.
    /// - Throws: An error if the voucher could not be created.
    public convenience init(recipes: [AttributeRecipe]) throws {
        let totalSize = recipes.reduce(0, { $0 + $1.size })
        let rawArray: mach_voucher_attr_raw_recipe_array_t = UnsafeMutablePointer<UInt8>.allocate(
            capacity: totalSize
        )
        defer { rawArray.deallocate() }
        var sizeRemaining = totalSize
        var rawRecipePointer = rawArray
        for recipe in recipes {
            let recipeSize = recipe.size
            // We are sort-of double-allocating here, but I guess that's the price we pay for having a separate `Recipe` class
            UnsafeMutableRawPointer(rawRecipePointer).copyMemory(
                from: recipe.rawValue, byteCount: recipeSize
            )
            sizeRemaining -= recipeSize
            rawRecipePointer = rawRecipePointer.advanced(by: recipeSize)
        }
        var voucherToUse: ipc_voucher_t = IPC_VOUCHER_NULL
        try Mach.Call(
            host_create_mach_voucher(
                mach_host_self(), rawArray,
                mach_msg_type_number_t(totalSize),
                &voucherToUse
            )
        )
        self.init(named: voucherToUse)
    }
    /// Get a recipe from the voucher.
    /// - Parameter key: The key to use.
    /// - Throws: An error if the recipe could not be retrieved.
    /// - Returns: The recipe.
    public func recipe(forKey key: AttributeKey) throws -> AttributeRecipe {
        // The kernel return an error if the size is too small or too large, so we use the maximum size. I'm not sure
        // why the kernel checks the size against a macro called MAX_RAW_RECIPE_ARRAY_SIZE when we're only extracting
        // a single recipe, but I have to work with it. Interestingly, the kernel doesn't check against this macro in
        // the case of extracting all recipes, which would have made more sense, given the name of the macro.
        var size = mach_voucher_attr_raw_recipe_size_t(MACH_VOUCHER_ATTR_MAX_RAW_RECIPE_ARRAY_SIZE)
        let rawRecipe = mach_voucher_attr_raw_recipe_t.allocate(capacity: Int(size))
        defer { rawRecipe.deallocate() }
        try Mach.Call(mach_voucher_extract_attr_recipe(self.name, key.rawValue, rawRecipe, &size))
        return AttributeRecipe(rawValue: rawRecipe)
    }

    /// A list of recipes in the voucher.
    public var recipes: [AttributeRecipe] {
        get throws {
            let rawArray = mach_voucher_attr_raw_recipe_array_t.allocate(
                capacity: Int(mach_voucher_attr_raw_recipe_size_t.max)
            )
            defer { rawArray.deallocate() }
            // The kernel return an error if the size is too small, so we use the maximum size.
            var size = mach_voucher_attr_raw_recipe_size_t.max
            try Mach.Call(mach_voucher_extract_all_attr_recipes(self.name, rawArray, &size))
            var recipes: [AttributeRecipe] = []
            var sizeRemaining = size
            var rawRecipePointer = rawArray
            while sizeRemaining > 0 {
                let recipeToAdd = AttributeRecipe(rawValue: rawRecipePointer)
                recipes.append(recipeToAdd)
                let recipeSize = mach_voucher_attr_raw_recipe_size_t(
                    MemoryLayout<mach_voucher_attr_recipe_data_t>.size
                        + recipeToAdd.content.count
                )
                sizeRemaining -= recipeSize
                rawRecipePointer = rawRecipePointer.advanced(by: Int(recipeSize))
            }
            return recipes
        }
    }
}
