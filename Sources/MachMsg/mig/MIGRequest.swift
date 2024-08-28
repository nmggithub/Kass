import Darwin

/// A Mach Interface Generator (MIG) request message.
public class MIGRequest<Payload>: MachMessage<Payload> {
    /// The remote port to send the MIG request to.
    public var migRemotePort: mach_port_t {
        get { self.header.remotePort.port }
        set {
            self.header.remotePort = .init(
                port: newValue,
                disposition: .copySend
            )
        }
    }
    /// The reply port to receive the MIG reply on.
    public var migReplyPort: mach_port_t {
        get { self.header.localPort.port }
        set {
            self.header.localPort = .init(
                port: newValue,
                disposition: .makeSendOnce
            )
        }
    }

    /// Create a new MIG request.
    /// - Parameters:
    ///   - descriptors: The descriptors of the MIG request.
    ///   - payload: The payload of the MIG request.
    ///   - payloadSize: The size of the payload for the MIG request (ignored if `payloadType is specified`).
    /// - Important: If you will be using an untyped payload, you must specify the size of the payload in bytes in lieu of a payload type.
    public init(
        descriptors: [any MachMessageDescriptor]? = nil,
        payload: Payload? = nil,
        payloadSize: Int? = nil
    ) {
        let hasDescriptors = descriptors != nil
        super.init(
            descriptorTypes: hasDescriptors ? descriptors!.map { type(of: $0) } : nil,
            payloadType: payload != nil ? Payload.self : Never.self as! Payload.Type,
            payloadSize: payloadSize
        )
        self.payload = payload
        if hasDescriptors { self.descriptors!.list = descriptors! }
        self.migReplyPort = mig_get_reply_port()
    }
}

/// A Mach Interface Generator (MIG) request message with an untyped payload.
public class UntypedMIGRequest: MIGRequest<Never> {
    /// Create a new untyped MIG request with the given payload size.
    /// - Parameters:
    ///   - payloadSize: The size of the payload in bytes.
    ///   - descriptors: The types descriptors of the MIG request, if any.
    public init(
        payloadSize: mach_msg_size_t = 0,
        descriptors: [any MachMessageDescriptor]? = nil
    ) {
        super.init(
            descriptors: descriptors,
            payloadSize: Int(payloadSize)
        )
    }
}
