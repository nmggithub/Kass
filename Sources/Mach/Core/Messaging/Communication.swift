import Darwin.Mach

// MARK: - Helper Extensions
extension Mach.Message {
    /// The size to pass to `mach_msg` for sending the message.
    internal var sendSize: mach_msg_size_t {
        let unalignedSize =
            MemoryLayout<mach_msg_header_t>.size
            + bodySize
            + payloadSize
        // The `mach_msg` kernel call expects the size to be aligned.
        return mach_msg_size_t((unalignedSize + (Self.alignment - 1)) & ~(Self.alignment - 1))
    }

    /// The default maximum size for receiving messages.
    @usableFromInline
    internal static let defaultMaxReceiveSize: Int = 1024

    /// Allocates a transient buffer for receiving messages, set to a given size.
    fileprivate static func transientBuffer(_ size: consuming Int) -> UnsafeMutableRawBufferPointer
    {
        let actualSize = max(size, MemoryLayout<mach_msg_header_t>.size)  // We just go ahead and round up if needed and don't tell the user.
        let bufferPointer = UnsafeMutableRawPointer.allocate(
            byteCount: actualSize,
            alignment: MemoryLayout<mach_msg_header_t>.alignment
        )
        let buffer = UnsafeMutableRawBufferPointer(start: bufferPointer, count: actualSize)
        buffer.initializeMemory(as: UInt8.self, repeating: 0)
        return buffer
    }
}

// MARK: - Sending and Receiving
extension Mach.Message {
    /// Calls the `mach_msg` kernel call.
    public static func message(
        _ messageBuffer: UnsafeMutablePointer<mach_msg_header_t>,
        options: Mach.MessageOptions = [],
        sendSize: mach_msg_size_t,
        receiveSize: mach_msg_size_t,
        receivePort: Mach.Port = Mach.Port.Nil,
        timeout: mach_msg_timeout_t = MACH_MSG_TIMEOUT_NONE,
        notifyPort: Mach.Port = Mach.Port.Nil
    ) throws {
        try Mach.call(
            mach_msg(
                messageBuffer,
                options.rawValue,
                sendSize,
                receiveSize,
                receivePort.name,
                timeout,
                notifyPort.name
            )
        )
    }

    /// Sends a message.
    /// - Warning: The `remotePort` parameter will override the remote port in the message header.
    /// - Warning: The `remoteDisposition` parameter will override the remote port disposition in the message header.
    public static func send(
        _ message: Mach.Message,
        to remotePort: Mach.Port? = nil,
        withDisposition remoteDisposition: Mach.PortDisposition? = nil,
        options: consuming Mach.MessageOptions = [],
        timeout: mach_msg_timeout_t = MACH_MSG_TIMEOUT_NONE
    ) throws {
        options.insert(.send)
        options.remove(.receive)
        if timeout != MACH_MSG_TIMEOUT_NONE { options.insert(.sendTimeout) }
        if let remotePortOverride = remotePort { message.header.remotePort = remotePortOverride }
        if let remoteDispositionOverride = remoteDisposition {
            message.header.bits.remotePortDisposition = remoteDispositionOverride
        }
        try message.withUnsafeSerializedMessage {
            try Self.message(
                $0, options: options, sendSize: message.sendSize,
                receiveSize: 0, receivePort: Mach.Port.Nil, timeout: timeout,
                notifyPort: Mach.Port.Nil
            )
        }
    }

    /// Sends a message and receive a message.
    /// - Warning: This function will block until a message is received.
    /// - Warning: The `remotePort` parameter will override the remote port in the message header.
    /// - Warning: The `receivePort` parameter will override the local port in the message header.
    /// - Warning: The `remoteDisposition` parameter will override the remote port disposition in the message header.
    /// - Warning: The `localDisposition` parameter will override the local port disposition in the message header.
    public static func send<ReceiveMessage: Mach.Message>(
        _ message: Mach.Message,
        to remotePort: Mach.Port? = nil,
        withDisposition remoteDisposition: Mach.PortDisposition? = nil,
        receiving receiveType: ReceiveMessage.Type = ReceiveMessage.self,
        ofMaxSize maxSize: Int = Mach.Message.defaultMaxReceiveSize,
        from receivePort: Mach.Port? = nil,
        withDisposition localDisposition: Mach.PortDisposition? = nil,
        options: consuming Mach.MessageOptions = [],
        timeout: mach_msg_timeout_t = MACH_MSG_TIMEOUT_NONE
    ) throws -> ReceiveMessage {
        options.insert(.send)
        options.insert(.receive)
        if timeout != MACH_MSG_TIMEOUT_NONE {
            options.insert(.sendTimeout)
            options.insert(.receiveTimeout)
        }
        if let remotePortOverride = remotePort { message.header.remotePort = remotePortOverride }
        if let receivePortOverride = receivePort { message.header.localPort = receivePortOverride }
        if let remoteDispositionOverride = remoteDisposition {
            message.header.bits.remotePortDisposition = remoteDispositionOverride
        }
        if let localDispositionOverride = localDisposition {
            message.header.bits.localPortDisposition = localDispositionOverride
        }
        return try message.withUnsafeSerializedMessage {
            let originalMessageBuffer = UnsafeRawBufferPointer(
                start: $0, count: Int(message.sendSize)
            )
            let rawMessageBuffer = Mach.Message.transientBuffer(max(maxSize, Int(message.sendSize)))
            defer { rawMessageBuffer.deallocate() }
            rawMessageBuffer.copyMemory(from: originalMessageBuffer)
            let messageBuffer = rawMessageBuffer.baseAddress!  // We control `rawMessageBuffer`, so this is safe.
                .bindMemory(to: mach_msg_header_t.self, capacity: 1)
            try Self.message(
                messageBuffer, options: options, sendSize: message.sendSize,
                receiveSize: mach_msg_size_t(rawMessageBuffer.count),
                receivePort: message.header.localPort, timeout: timeout,
                notifyPort: Mach.Port.Nil
            )
            return ReceiveMessage.init(headerPointer: messageBuffer)
        }
    }

    /// Receives a message.
    /// - Warning: This function will block until a message is received.
    public static func receive<ReceiveMessage: Mach.Message>(
        _ messageType: ReceiveMessage.Type = ReceiveMessage.self,
        ofMaxSize maxSize: Int = Mach.Message.defaultMaxReceiveSize,
        from localPort: Mach.Port,
        options: consuming Mach.MessageOptions = [],
        timeout: mach_msg_timeout_t = MACH_MSG_TIMEOUT_NONE
    ) throws -> ReceiveMessage {
        options.remove(.send)
        options.insert(.receive)
        if timeout != MACH_MSG_TIMEOUT_NONE { options.insert(.receiveTimeout) }
        let rawMessageBuffer = Mach.Message.transientBuffer(maxSize)
        defer { rawMessageBuffer.deallocate() }
        let messageBuffer = rawMessageBuffer.baseAddress!.bindMemory(
            to: mach_msg_header_t.self, capacity: 1
        )
        try Self.message(
            messageBuffer, options: options, sendSize: 0,
            receiveSize: mach_msg_size_t(rawMessageBuffer.count), receivePort: localPort,
            timeout: timeout,
            notifyPort: Mach.Port.Nil
        )
        return ReceiveMessage.init(headerPointer: messageBuffer)
    }
}
