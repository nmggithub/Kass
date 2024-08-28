import CCompat
import Darwin
import Foundation

/// A helper class for sending and receiving messages.
open class MachMessaging {
    /// Create an error from a return code.
    /// - Parameter ret: The return code.
    /// - Returns: An error representing the return code.
    private static func errorForReturnCode(_ ret: mach_msg_return_t) -> Error {
        NSError(domain: NSMachErrorDomain, code: Int(ret))
    }

    /// Send a message.
    /// - Parameters:
    ///   - message: The message to send.
    ///   - options: The options to use when sending the message.
    ///   - timeout: The timeout to use when sending the message.
    public static func send<SendPayload>(
        _ message: MachMessage<SendPayload>,
        options: consuming MachMsgOptions = [], timeout: mach_msg_timeout_t = 0
    ) throws {
        options.set(.send)
        options.unset(.receive)
        let sendSize = message.bufferSize
        let ret = mach_msg(
            message.header.pointer, options.rawValue,
            sendSize, 0, mach_port_t(MACH_PORT_NULL),
            timeout, mach_port_t(MACH_PORT_NULL)
        )
        guard ret == MACH_MSG_SUCCESS else { throw Self.errorForReturnCode(ret) }

    }

    /// Receive a message.
    /// - Parameters:
    ///   - message: The message to receive.
    ///   - options: The options to use when receiving the message.
    ///   - timeout: The timeout to use when receiving the message.
    public static func receive<ReceivePayload>(
        _ message: MachMessage<ReceivePayload>,
        options: consuming MachMsgOptions = [],
        timeout: mach_msg_timeout_t = 0
    ) throws {
        options.unset(.send)
        options.set(.receive)
        let receiveSize: mach_msg_size_t = message.bufferSize
        let ret = mach_msg(
            message.header.pointer, options.rawValue,
            0, receiveSize, message.header.localPort.port,
            timeout, mach_port_t(MACH_PORT_NULL)
        )
        guard ret == MACH_MSG_SUCCESS else { throw Self.errorForReturnCode(ret) }
    }

    /// Send a message and receive a response.
    /// - Parameters:
    ///   - sendMessage: The message to send.
    ///   - receiveMessage: The message to receive.
    ///   - options: The options to use when sending and receiving the message.
    ///   - timeout: The timeout to use when sending and receiving the message.
    /// - Remark: When finished, the receive message will contain the response.
    public static func sendAndReceive<SendPayload, ReceivePayload>(
        _ sendMessage: MachMessage<SendPayload>,
        receiveMessage: MachMessage<ReceivePayload>,
        options: consuming MachMsgOptions = [],
        timeout: mach_msg_timeout_t = 0
    ) throws {
        options.set(.send, .receive)
        let sendSize = sendMessage.messageSize  // does not include the trailer
        let receiveMax: mach_msg_size_t = receiveMessage.bufferSize  // does include the trailer

        // premake a transient message buffer, so that we are not mutating the original buffer
        let transient = UntypedMachMessage(
            payloadSize: max(receiveMax, sendSize)
                - mach_msg_size_t(MemoryLayout<mach_msg_header_t>.size)
        )
        try transient.copyIn(from: sendMessage)
        let ret = mach_msg(
            transient.header.pointer, options.rawValue | 0x3000003,
            sendSize, receiveMax, transient.header.localPort.port,
            timeout, mach_port_t(MACH_PORT_NULL)
        )
        guard ret == MACH_MSG_SUCCESS else { throw Self.errorForReturnCode(ret) }
        let endPointer = UnsafeMutableRawPointer(
            transient.startPointer
        ).advanced(by: Int(receiveMax))
        // zero out the remaining buffer space
        endPointer.initializeMemory(
            as: UInt8.self, repeating: 0, count: Int(transient.bufferSize - receiveMax)
        )
        try! receiveMessage.copyIn(from: transient)  // we can force-try here because we know it will succeed
        receiveMessage.cleanUpLeftoverData()  // clean up any leftover data from the sent message (as the buffer is reused)
    }
}
