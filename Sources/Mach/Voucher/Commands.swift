import Darwin.Mach
import Foundation

extension Mach.Voucher {

    /// A voucher attribute command.
    public protocol AttributeCommand: RawRepresentable<mach_voucher_attr_command_t> {}

    /// A Mach voucher attribute command for the .bank key.
    public enum BankAction: bank_action_t, AttributeCommand {
        case originatorPid = 1
        case personaToken = 2
        case personaId = 3
        case personaAdoptAny = 4
        case originatorProximatePid = 5
    }

    /// A Mach voucher attribute command for the .importance key.
    public enum ImportanceAction: mach_voucher_attr_importance_refs, AttributeCommand {
        case addExternal = 1  // not supported
        case dropExternal = 2
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
        key: AttributeKey, command: any AttributeCommand, in: Any? = nil, as: T.Type
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
        key: AttributeKey, command: any AttributeCommand, in: Any? = nil
    ) throws -> Data? {
        let inContent = `in` != nil ? withUnsafeBytes(of: `in`, { Data($0) }) : Data()
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
