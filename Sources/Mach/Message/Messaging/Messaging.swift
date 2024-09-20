import CCompat
import Darwin.Mach

extension Mach.Message {
    /// The size to pass to `mach_msg` for sending the message.
    var sendSize: mach_msg_size_t {
        let unalignedSize =
            MemoryLayout<mach_msg_header_t>.size
            + bodySize
            + payloadSize
        return mach_msg_size_t(unalignedSize + (Self.alignment - 1) & ~(Self.alignment - 1))
    }
}

extension Mach {
    /// A set of helper functions for sending and receiving messages.
    public struct Messaging {
        /// Call the `mach_msg` syscall.
        /// - Parameters:
        ///   - messageBuffer: The message buffer. This buffer is reused for receiving messages.
        ///   - options: The options for the syscall.
        ///   - sendSize: The size of the message to send.
        ///   - receiveSize: The size of the message to receive.
        ///   - receivePort: The local port to receive the message on.
        ///   - timeout: The timeout for the syscall.
        ///   - notifyPort: The port to notify on timeout.
        /// - Throws: An error if the syscall fails.
        public static func syscall(
            _ messageBuffer: UnsafeMutablePointer<mach_msg_header_t>,
            options: Set<Option> = [],
            sendSize: mach_msg_size_t,
            receiveSize: mach_msg_size_t,
            receivePort: Mach.Port = Mach.Port.Nil,
            timeout: mach_msg_timeout_t = MACH_MSG_TIMEOUT_NONE,
            notifyPort: Mach.Port = Mach.Port.Nil
        ) throws {
            try Mach.call(
                mach_msg(
                    messageBuffer,
                    options.bitmap(),
                    sendSize,
                    receiveSize,
                    receivePort.name,
                    timeout,
                    notifyPort.name
                ))
        }
        /// The default maximum size for receiving messages.
        @usableFromInline
        static let defaultMaxReceiveSize: Int = 1024
        /// A transient buffer for receiving messages, set to a given maximum size.
        /// - Parameter size: The size of the buffer.
        /// - Returns: The buffer.
        /// - Warning: The size must be at least the size of a `mach_msg_header_t`.
        /// - Warning: The size must not be unreasonably large.
        private static func transientBuffer(_ size: Int) -> UnsafeMutableRawBufferPointer {
            let bufferPointer = UnsafeMutableRawPointer.allocate(
                byteCount: size,
                alignment: MemoryLayout<mach_msg_header_t>.alignment
            )
            let buffer = UnsafeMutableRawBufferPointer(start: bufferPointer, count: size)
            buffer.initializeMemory(as: UInt8.self, repeating: 0)
            return buffer
        }
        /// Send a message.
        /// - Parameters:
        ///   - message: The message to send.
        ///   - remotePort: The port to send the message to.
        ///   - options: The options for sending the message.
        ///   - timeout: The timeout for sending the message.
        /// - Note: Don't specify `remotePort` to use remote port specified in the message header.
        public static func send(
            _ message: Mach.Message,
            to remotePort: Mach.Port? = nil,
            options: consuming Set<Option> = [],
            timeout: mach_msg_timeout_t = MACH_MSG_TIMEOUT_NONE
        ) throws {
            options.insert(.send)
            options.remove(.receive)
            if timeout != MACH_MSG_TIMEOUT_NONE {
                options.insert(.sendTimeout)
            }
            if remotePort != nil {
                message.header.remotePort = remotePort!
            }
            try Self.syscall(
                message.rawValue, options: options, sendSize: message.sendSize,
                receiveSize: 0, receivePort: Mach.Port.Nil, timeout: timeout,
                notifyPort: Mach.Port.Nil
            )
        }
        /// Send a message and receive a response.
        /// - Parameters:
        ///   - message: The message to send.
        ///   - remotePort: The port to send the message to.
        ///   - receiveType: The type of message to receive.
        ///   - localPort: The port to receive the response on.
        ///   - options: The options for sending and receiving the message.
        ///   - timeout: The timeout for sending and receiving the message.
        /// - Note: Don't specify `remotePort` to use remote port specified in the message header.
        /// - Note: Don't specify `localPort` to use local port specified in the message header.
        public static func send<ReceiveMessage: Mach.Message>(
            _ message: Mach.Message,
            to remotePort: Mach.Port? = nil,
            receiving receiveType: ReceiveMessage.Type,
            ofMaxSize maxSize: Int = Self.defaultMaxReceiveSize,
            on localPort: Mach.Port? = nil,
            options: consuming Set<Option> = [],
            timeout: mach_msg_timeout_t = 0
        ) throws -> ReceiveMessage {
            options.insert(.send)
            options.insert(.receive)
            if timeout != MACH_MSG_TIMEOUT_NONE {
                options.insert(.sendTimeout)
                options.insert(.receiveTimeout)
            }
            if remotePort != nil {
                message.header.remotePort = remotePort!
            }
            if localPort != nil {
                message.header.localPort = localPort!
            }
            let originalMessageBuffer = UnsafeRawBufferPointer(
                start: message.rawValue, count: Int(message.sendSize)
            )
            let rawMessageBuffer = self.transientBuffer(maxSize)
            defer { rawMessageBuffer.deallocate() }
            rawMessageBuffer.copyMemory(from: originalMessageBuffer)
            let messageBuffer = rawMessageBuffer.baseAddress!.bindMemory(
                to: mach_msg_header_t.self, capacity: 1
            )
            try Self.syscall(
                messageBuffer, options: options, sendSize: message.sendSize,
                receiveSize: mach_msg_size_t(rawMessageBuffer.count),
                receivePort: message.header.localPort, timeout: timeout,
                notifyPort: Mach.Port.Nil
            )
            let receivedMessage = ReceiveMessage.init(rawValue: messageBuffer)
            return receivedMessage
        }
        /// Receive a message.
        /// - Parameters:
        ///   - messageType: The type of message to receive.
        ///   - localPort: The port to receive the message on.
        ///   - options: The options for receiving the message.
        ///   - timeout: The timeout for receiving the message.
        public static func receive<ReceiveMessage: Mach.Message>(
            _ messageType: ReceiveMessage.Type = Mach.Message.self,
            ofMaxSize maxSize: Int = Self.defaultMaxReceiveSize,
            on localPort: Mach.Port,
            options: consuming Set<Option> = [],
            timeout: mach_msg_timeout_t = MACH_MSG_TIMEOUT_NONE
        ) throws -> ReceiveMessage {
            options.remove(.send)
            options.insert(.receive)
            if timeout != MACH_MSG_TIMEOUT_NONE {
                options.insert(.receiveTimeout)
            }
            let rawMessageBuffer = self.transientBuffer(maxSize)
            defer { rawMessageBuffer.deallocate() }
            let messageBuffer = rawMessageBuffer.baseAddress!.bindMemory(
                to: mach_msg_header_t.self, capacity: 1
            )
            try Self.syscall(
                messageBuffer, options: options, sendSize: 0,
                receiveSize: mach_msg_size_t(rawMessageBuffer.count), receivePort: localPort,
                timeout: timeout,
                notifyPort: Mach.Port.Nil
            )
            let receivedMessage = ReceiveMessage.init(rawValue: messageBuffer)
            return receivedMessage
        }
    }
}
