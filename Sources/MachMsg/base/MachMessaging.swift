import CCompat
import Darwin.Mach
import Foundation
import MachPort

extension MachMessage {
    /// The size to pass to `mach_msg` for sending the message.
    var sendSize: mach_msg_size_t {
        let unalignedSize =
            MemoryLayout<mach_msg_header_t>.size
            + bodySize
            + payloadSize
        return mach_msg_size_t(unalignedSize + (Self.alignment - 1) & ~(Self.alignment - 1))
    }
}

struct MachMessaging {
    /// The default maximum size for receiving messages.
    private static let defaultMaxReceiveSize: Int = 1024
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
    ///   - remoteMessagePort: The port to send the message to. Don't specify to use the message's remote port.
    ///   - options: The options for sending the message.
    ///   - timeout: The timeout for sending the message.
    static func send(
        _ message: MachMessage,
        to remoteMessagePort: MachMessagePort? = nil,
        options: consuming MachMsgOptions = [],
        timeout: mach_msg_timeout_t = 0
    ) throws {
        options.set(.send)
        options.unset(.receive)
        if let remoteMessagePort = remoteMessagePort {
            message.header.remoteMessagePort = remoteMessagePort
        }
        let ret = mach_msg(
            message.rawValue, options.rawValue,
            message.sendSize, 0, (nil as MachPort).rawValue,
            timeout, (nil as MachPort).rawValue
        )
        guard ret == MACH_MSG_SUCCESS else {
            throw NSError(domain: NSMachErrorDomain, code: Int(ret))
        }
    }
    /// Send a message and receive a response.
    /// - Parameters:
    ///   - message: The message to send.
    ///   - remoteMessagePort: The port to send the message to. Don't specify to use the message's remote port.
    ///   - receiveType: The type of message to receive.
    ///   - localMessagePort: The port to receive the response on. Don't specify to use the message's local port.
    ///   - options: The options for sending and receiving the message.
    ///   - timeout: The timeout for sending and receiving the message.
    static func send<ReceiveMessage: MachMessage>(
        _ message: MachMessage,
        to remoteMessagePort: MachMessagePort? = nil,
        receiving receiveType: ReceiveMessage.Type,
        ofMaxSize maxSize: Int = Self.defaultMaxReceiveSize,
        on localMessagePort: MachMessagePort? = nil,
        options: consuming MachMsgOptions = [],
        timeout: mach_msg_timeout_t = 0
    ) throws -> ReceiveMessage {
        options.set(.send, .receive)
        if let remoteMessagePort = remoteMessagePort {
            message.header.remoteMessagePort = remoteMessagePort
        }
        if let localMessagePort = localMessagePort {
            message.header.localMessagePort = localMessagePort
        }
        let originalMessageBuffer = UnsafeRawBufferPointer(
            start: message.rawValue, count: Int(message.sendSize)
        )
        let rawMessageBuffer = self.transientBuffer(maxSize)
        rawMessageBuffer.copyMemory(from: originalMessageBuffer)
        let messageBuffer = rawMessageBuffer.baseAddress!.bindMemory(
            to: mach_msg_header_t.self, capacity: 1
        )
        let ret = mach_msg(
            messageBuffer, options.rawValue, message.sendSize,
            mach_msg_size_t(rawMessageBuffer.count),
            message.header.localPort.rawValue, timeout,
            (nil as MachPort).rawValue
        )
        guard ret == MACH_MSG_SUCCESS else {
            throw NSError(domain: NSMachErrorDomain, code: Int(ret))
        }
        let receivedMessage = ReceiveMessage.init(rawValue: messageBuffer)
        rawMessageBuffer.deallocate()
        return receivedMessage
    }
    /// Receive a message.
    /// - Parameters:
    ///   - messageType: The type of message to receive.
    ///   - localPort: The port to receive the message on.
    ///   - options: The options for receiving the message.
    ///   - timeout: The timeout for receiving the message.
    static func receive<ReceiveMessage: MachMessage>(
        _ messageType: ReceiveMessage.Type,
        ofMaxSize maxSize: Int = Self.defaultMaxReceiveSize,
        on localPort: MachPort,
        options: consuming MachMsgOptions = [],
        timeout: mach_msg_timeout_t = 0
    ) throws -> ReceiveMessage {
        options.unset(.send)
        options.set(.receive)

        let rawMessageBuffer = self.transientBuffer(maxSize)
        let messageBuffer = rawMessageBuffer.baseAddress!.bindMemory(
            to: mach_msg_header_t.self, capacity: 1
        )
        let ret = mach_msg(
            messageBuffer, options.rawValue, 0,
            mach_msg_size_t(rawMessageBuffer.count),
            localPort.rawValue, timeout,
            (nil as MachPort).rawValue
        )
        guard ret == MACH_MSG_SUCCESS else {
            throw NSError(domain: NSMachErrorDomain, code: Int(ret))
        }
        let receivedMessage = ReceiveMessage.init(rawValue: messageBuffer)
        rawMessageBuffer.deallocate()
        return receivedMessage
    }
}
