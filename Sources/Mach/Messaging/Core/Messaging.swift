import CCompat
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
    fileprivate static func transientBuffer(_ size: Int) -> UnsafeMutableRawBufferPointer {
        guard size >= MemoryLayout<mach_msg_header_t>.size else {
            fatalError("The requested buffer size is too small!")
        }
        let bufferPointer = UnsafeMutableRawPointer.allocate(
            byteCount: size,
            alignment: MemoryLayout<mach_msg_header_t>.alignment
        )
        let buffer = UnsafeMutableRawBufferPointer(start: bufferPointer, count: size)
        buffer.initializeMemory(as: UInt8.self, repeating: 0)
        return buffer
    }
}

// MARK: - Message Sending and Receiving
extension Mach {
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
    public static func sendMessage(
        _ message: Mach.Message,
        to remotePort: Mach.Port? = nil,
        options: consuming Mach.MessageOptions = [],
        timeout: mach_msg_timeout_t = MACH_MSG_TIMEOUT_NONE
    ) throws {
        options.insert(.send)
        options.remove(.receive)
        if timeout != MACH_MSG_TIMEOUT_NONE { options.insert(.sendTimeout) }
        if let remotePortOverride = remotePort { message.header.remotePort = remotePortOverride }
        try Mach.message(
            message.rawValue, options: options, sendSize: message.sendSize,
            receiveSize: 0, receivePort: Mach.Port.Nil, timeout: timeout,
            notifyPort: Mach.Port.Nil
        )
    }

    /// Sends a message and receive a message.
    /// - Warning: The `remotePort` parameter will override the remote port in the message header.
    /// - Warning: The `receivePort` parameter will override the local port in the message header.
    public static func sendMessage<ReceiveMessage: Mach.Message>(
        _ message: Mach.Message,
        to remotePort: Mach.Port? = nil,
        receiving receiveType: ReceiveMessage.Type,
        ofMaxSize maxSize: Int = Mach.Message.defaultMaxReceiveSize,
        on receivePort: Mach.Port? = nil,
        options: consuming Mach.MessageOptions = [],
        timeout: mach_msg_timeout_t = 0
    ) throws -> ReceiveMessage {
        options.insert(.send)
        options.insert(.receive)
        if timeout != MACH_MSG_TIMEOUT_NONE {
            options.insert(.sendTimeout)
            options.insert(.receiveTimeout)
        }
        if let remotePortOverride = remotePort { message.header.remotePort = remotePortOverride }
        if let receivePortOverride = receivePort { message.header.localPort = receivePortOverride }
        let originalMessageBuffer = UnsafeRawBufferPointer(
            start: message.rawValue, count: Int(message.sendSize)
        )
        let rawMessageBuffer = Mach.Message.transientBuffer(maxSize)
        defer { rawMessageBuffer.deallocate() }
        rawMessageBuffer.copyMemory(from: originalMessageBuffer)
        let messageBuffer = rawMessageBuffer.baseAddress!  // We control `rawMessageBuffer`, so this is safe.
            .bindMemory(to: mach_msg_header_t.self, capacity: 1)
        try Mach.message(
            messageBuffer, options: options, sendSize: message.sendSize,
            receiveSize: mach_msg_size_t(rawMessageBuffer.count),
            receivePort: message.header.localPort, timeout: timeout,
            notifyPort: Mach.Port.Nil
        )
        return ReceiveMessage.init(rawValue: messageBuffer)
    }

    /// Receives a message.
    public static func receiveMessage<ReceiveMessage: Mach.Message>(
        _ messageType: ReceiveMessage.Type = Mach.Message.self,
        ofMaxSize maxSize: Int = Mach.Message.defaultMaxReceiveSize,
        on localPort: Mach.Port,
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
        try Mach.message(
            messageBuffer, options: options, sendSize: 0,
            receiveSize: mach_msg_size_t(rawMessageBuffer.count), receivePort: localPort,
            timeout: timeout,
            notifyPort: Mach.Port.Nil
        )
        return ReceiveMessage.init(rawValue: messageBuffer)
    }
}
