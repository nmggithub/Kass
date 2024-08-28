import Foundation

/// A Mach voucher attribute recipe.
public class MachVoucherAttrRecipe: RawRepresentable {
    /// A Mach voucher attribute recipe command.
    public typealias Command = MachVoucherAttrRecipeCommand
    /// A Mach voucher attribute recipe key.
    public typealias Key = MachVoucherAttrRecipeKey
    /// The raw recipe pointer.
    public let rawValue: mach_voucher_attr_raw_recipe_t
    /// The typed recipe pointer.
    public var typedValue: mach_voucher_attr_recipe_t {
        self.rawValue.withMemoryRebound(
            to: mach_voucher_attr_recipe_data_t.self, capacity: 1
        ) { $0 }
    }
    /// Create a new recipe with the given raw value.
    public required init(rawValue: mach_voucher_attr_raw_recipe_t) {
        self.rawValue = rawValue
    }
    /// The key of the recipe.
    public var key: Key? {
        Key(rawValue: self.typedValue.pointee.key)
    }
    /// The command of the recipe.
    public var command: Command? {
        Command(rawValue: self.typedValue.pointee.command)
    }
    /// The content of the recipe.
    public var content: Data {
        Data(
            bytes: UnsafeRawPointer(self.rawValue.advanced(by: 1)),
            count: Int(self.typedValue.pointee.content_size)
        )
    }
    /// The size of the recipe.
    public var size: Int {
        MemoryLayout<mach_voucher_attr_recipe_data_t>.size
            + Int(self.typedValue.pointee.content_size)
    }
    /// Create a new recipe with the given key, command, and content.
    /// - Parameters:
    ///   - key: The key of the recipe.
    ///   - command: The command of the recipe.
    ///   - content: The content of the recipe.
    public init(
        key: Key, command: Command,
        content: Data? = nil
    ) {
        let contentSize = content?.count ?? 0
        let pointer = UnsafeMutablePointer<UInt8>.allocate(
            capacity: MemoryLayout<mach_voucher_attr_recipe_data_t>.size + contentSize
        )
        pointer.withMemoryRebound(
            to: mach_voucher_attr_recipe_data_t.self, capacity: 1
        ) { recipe in
            recipe.pointee.key = key.rawValue
            recipe.pointee.command = command.rawValue
            recipe.pointee.content_size = mach_msg_size_t(contentSize)
            if content != nil {
                let contentPointer = recipe.advanced(by: 1)
                UnsafeMutableRawPointer(mutating: contentPointer).copyMemory(
                    from: (content! as NSData).bytes,
                    // We're in a block under the condition that `content != nil`, thus `contentSize` should be the
                    // same as `content!.count`. We'll use `contentSize` here to avoid force-unwrapping `content`.
                    byteCount: contentSize
                )
            }
        }
        self.rawValue = pointer
    }
    deinit {
        self.rawValue.deallocate()
    }
}
