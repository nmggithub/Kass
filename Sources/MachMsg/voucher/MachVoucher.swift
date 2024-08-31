import Foundation

/// A Mach voucher.
public class MachVoucher: RawRepresentable {
    /// A Mach voucher command.
    public typealias Command = MachVoucherAttrCommand
    /// A Mach voucher recipe.
    public typealias Recipe = MachVoucherAttrRecipe
    /// A Mach voucher key.
    public typealias Key = MachVoucherAttrKey
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
    ///   - in: The input content.
    ///   - as: The type to cast the output content to.
    /// - Throws: An error if the command could not be invoked.
    /// - Returns: The output content.
    public func command<T>(
        key: Key, command: any Command, in: Any? = nil, as: T.Type
    ) throws -> T? {
        return try self.command(key: key, command: command, in: `in`).map({
            $0.withUnsafeBytes({ $0.load(as: T.self) })
        })
    }

    /// Invoke a command on the voucher.
    /// - Parameters:
    ///   - key: The key to use.
    ///   - command: The command to invoke.
    ///   - in: The input content.
    /// - Throws: An error if the command could not be invoked.
    /// - Returns: The output content as a `Data` object.
    public func command(
        key: Key, command: any Command, in: Any? = nil
    ) throws -> Data? {
        let inContent = `in` != nil ? withUnsafeBytes(of: `in`, { Data($0) }) : Data()
        let outContentPointer = mach_voucher_attr_content_t.allocate(capacity: 1)
        var outContentSize = mach_voucher_attr_content_size_t.max
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
        guard outContentSize > 0 else {
            return nil
        }
        return Data(
            bytes: outContentPointer, count: Int(outContentSize)
        )
    }

    /// Get a recipe from the voucher.
    /// - Parameter key: The key to use.
    /// - Throws: An error if the recipe could not be retrieved.
    /// - Returns: The recipe.
    public func recipe(forKey key: Key) throws -> Recipe {
        // The kernel return an error if the size is too small or too large, so we use the maximum size. I'm not sure
        // why the kernel checks the size against a macro called MAX_RAW_RECIPE_ARRAY_SIZE when we're only extracting
        // a single recipe, but I have to work with it. Interestingly, the kernel doesn't check against this macro in
        // the case of extracting all recipes, which would have made more sense, given the name of the macro.
        var size = mach_voucher_attr_raw_recipe_size_t(MACH_VOUCHER_ATTR_MAX_RAW_RECIPE_ARRAY_SIZE)
        let rawRecipe = mach_voucher_attr_raw_recipe_t.allocate(capacity: Int(size))
        defer { rawRecipe.deallocate() }
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

    deinit {
        mach_voucher_deallocate(self.rawValue)
    }
}
