import Darwin
import Foundation

/// A Mach message with an untyped payload.
public class UntypedMachMessage: MachMessage<Never> {
    /// Create a new MachMessage with the given payload size.
    /// - Parameters
    ///     - payloadSize: The size of the payload in bytes.
    ///     - descriptorTypes: The types of the descriptors for the message, if any.
    public init(
        payloadSize: mach_msg_size_t = 0,
        descriptorTypes: [any MachMessageDescriptor.Type]? = nil
    ) {
        super.init(
            descriptorTypes: descriptorTypes,
            payloadType: Never.self,
            payloadSize: Int(payloadSize)
        )
    }

    /// A `Data` representation of the payload, if it exists.
    /// - Important: Setting this property will have no effect if the new value is `nil`, or if it is larger than the `payloadSize`.
    public var payloadData: Data? {
        get {
            // These are both testing essentially the same thing (`payloadPointer` should
            // only be nil if the `payloadSize` is zero), but it's good to have the safe.
            guard
                self.payloadPointer != nil,
                self.payloadSize > 0
            else { return nil }
            return Data(bytes: self.payloadPointer!, count: self.payloadSize)
        }
        set {
            // These are both testing essentially the same thing (`payloadPointer` should
            // only be nil if the `payloadSize` is zero), but it's good to have the safe.
            guard
                self.payloadPointer != nil,
                self.payloadSize > 0
            else { return }
            guard let newData = newValue else { return }  // no-op if the data is nil
            guard newData.count <= self.payloadSize else { return }  // no-op if the data is too large
            let rawPayloadPointer = UnsafeMutableRawPointer(self.payloadPointer!)
            // zero out the payload (in case the new data is smaller than the old data)
            rawPayloadPointer.initializeMemory(
                as: UInt8.self, repeating: 0, count: self.payloadSize
            )
            // copy the new data into the payload
            rawPayloadPointer.copyMemory(
                from: (newData as NSData).bytes, byteCount: Int(payloadSize)
            )

        }
    }
}
