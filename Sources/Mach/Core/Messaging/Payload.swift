import Foundation

// MARK: - Message Payload
extension Mach {
    /// A message payload.
    public protocol MessagePayload {
        /// Converts the payload to Data for embedding in a message
        var payloadData: Data { get }

        /// Loads a payload from Data received from a message
        static func fromPayloadData(_ data: Data) -> Self?
    }

    /// A message with a typed payload.
    public protocol MessageWithTypedPayload: Mach.Message {
        associatedtype PayloadType: Mach.MessagePayload
        /// The typed message payload.
        var typedPayload: PayloadType? { get set }
    }
}

extension Mach.MessageWithTypedPayload {
    /// The typed message payload.
    public var typedPayload: PayloadType? {
        get {
            guard let payloadData = self.payload else { return nil }
            return PayloadType.fromPayloadData(payloadData)
        }
        set {
            self.payload = newValue?.payloadData
        }
    }

    /// Creates a message with a set of descriptors and a payload.
    public init(
        descriptors: [any Mach.MessageDescriptor]? = nil,
        typedPayload: PayloadType
    ) {
        self.init(descriptors: descriptors, payload: typedPayload.payloadData)
    }
}

// MARK: - Trivial Payload
extension Mach {
    /// A payload with a fixed length and trivial representation.
    public protocol TrivialMessagePayload: Mach.MessagePayload, BitwiseCopyable {}
}

extension Mach.TrivialMessagePayload {
    public static func fromPayloadData(_ data: Data) -> Self? {
        guard data.count == MemoryLayout<Self>.size else { return nil }
        return data.withUnsafeBytes { $0.load(as: Self.self) }
    }

    public var payloadData: Data {
        withUnsafeBytes(of: self) { Data($0) }
    }
}

// MARK: - Data Payload
/// Data as a message payload.
extension Data: Mach.MessagePayload {
    /// Loads a `Data` as payload data.
    public static func fromPayloadData(_ data: Data) -> Data? { data }

    /// Itself as payload data.
    public var payloadData: Data { self }
}

// MARK: - Non-Existent Payload
/// A non-existent payload.
extension Never: Mach.MessagePayload {
    /// Returns `nil`.
    public static func fromPayloadData(_ data: Data) -> Self? { nil }

    /// Zero-length empty data.
    public var payloadData: Data { Data() }
}
