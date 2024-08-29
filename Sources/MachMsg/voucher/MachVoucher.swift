import Foundation

/// A Mach voucher.
public class MachVoucher: RawRepresentable {
    /// A Mach voucher recipe.
    public typealias Recipe = MachVoucherAttrRecipe
    /// The raw voucher.
    public let rawValue: ipc_voucher_t
    public required init(rawValue: mach_voucher_t) {
        self.rawValue = rawValue
    }

    /// Create a new Mach voucher with the given recipes.
    /// - Parameter recipes: The recipes to create the voucher with.
    /// - Throws: An error if the voucher could not be created.
    public init(recipes: [Recipe]) throws {
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
        let ret = host_create_mach_voucher(
            mach_host_self(), rawArray,
            mach_msg_type_number_t(totalSize),
            &voucherToUse
        )
        guard ret == KERN_SUCCESS else {
            throw NSError(domain: NSMachErrorDomain, code: Int(ret))
        }
        self.rawValue = voucherToUse
    }

    /// Invoke a command on the voucher.
    /// - Parameters:
    ///   - key: The key to use.
    ///   - command: The command to invoke.
    ///   - inContent: The input content.
    ///   - outContent: The output content.
    /// - Throws: An error if the command could not be invoked.
    public func command(
        key: Recipe.Key, command: Recipe.Command, inContent: Data,
        outContent: inout Data
    ) throws {
        let outContentPointer = mach_voucher_attr_content_t.allocate(capacity: 1)
        var outContentSize = mach_voucher_attr_content_size_t(0)
        let ret = mach_voucher_attr_command(
            self.rawValue, key.rawValue, command.rawValue,
            UnsafeMutablePointer(
                mutating: (inContent as NSData).bytes.assumingMemoryBound(to: UInt8.self)
            ),
            mach_voucher_attr_content_size_t(inContent.count),
            outContentPointer, &outContentSize
        )
        guard ret == KERN_SUCCESS else {
            throw NSError(domain: NSMachErrorDomain, code: Int(ret))
        }
        outContent = Data(
            bytes: outContentPointer, count: Int(outContentSize)
        )
    }

    /// Get a recipe from the voucher.
    /// - Parameter key: The key to use.
    /// - Throws: An error if the recipe could not be retrieved.
    /// - Returns: The recipe.
    public func recipe(forKey key: Recipe.Key) throws -> Recipe {
        let rawRecipe = mach_voucher_attr_raw_recipe_t.allocate(
            capacity: Int(mach_voucher_attr_raw_recipe_size_t.max)
        )
        defer { rawRecipe.deallocate() }
        // The kernel return an error if the size is too small, so we use the maximum size.
        var size = mach_voucher_attr_raw_recipe_size_t.max
        let ret = mach_voucher_extract_attr_recipe(self.rawValue, key.rawValue, rawRecipe, &size)
        guard ret == KERN_SUCCESS else {
            throw NSError(domain: NSMachErrorDomain, code: Int(ret))
        }
        return Recipe(rawValue: rawRecipe)
    }

    /// A list of recipes in the voucher.
    public var recipes: [Recipe] {
        let rawArray = mach_voucher_attr_raw_recipe_array_t.allocate(
            capacity: Int(mach_voucher_attr_raw_recipe_size_t.max)
        )
        defer { rawArray.deallocate() }
        // The kernel return an error if the size is too small, so we use the maximum size.
        var size = mach_voucher_attr_raw_recipe_size_t.max
        let ret = mach_voucher_extract_all_attr_recipes(self.rawValue, rawArray, &size)
        guard ret == KERN_SUCCESS else {
            // No recipes could be extracted (we can't throw from an accessor, so we return an empty array).
            return []
        }
        var recipes: [Recipe] = []
        var sizeRemaining = size
        var rawRecipePointer = rawArray
        while sizeRemaining > 0 {
            let recipeToAdd = Recipe(rawValue: rawRecipePointer)
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
