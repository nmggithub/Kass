import Foundation

/// A Mach voucher attribute recipe.
public class MachVoucherAttrRecipe: RawRepresentable {
    /// A Mach voucher attribute recipe command.
    public typealias Command = MachVoucherAttrRecipeCommand
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
    public var key: MachVoucher.Key? {
        MachVoucher.Key(rawValue: self.typedValue.pointee.key)
    }
    /// The command of the recipe.
    public var command: Command? {
        Command(rawValue: self.typedValue.pointee.command)
    }
    /// The previous voucher.
    public var previous: MachVoucher? {
        return MachVoucher(rawValue: self.typedValue.pointee.previous_voucher)
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
    /// Create a new recipe with the given key, command, and content.
    /// - Parameters:
    ///   - key: The key of the recipe.
    ///   - command: The command of the recipe.
    ///   - content: The content of the recipe.
    public init(
        key: MachVoucher.Key, command: Command,
        previous: MachVoucher? = nil,
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
            recipe.pointee.previous_voucher = previous?.rawValue ?? IPC_VOUCHER_NULL
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
