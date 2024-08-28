import CCompat
import Darwin

/// A connection to a MIG server.
open class MIGConnection: ServiceConnection {
    /// A MIG request.
    public typealias Request = MIGRequest
    /// A MIG reply.
    public typealias Reply = MIGReply

    /// An error representing a failure to parse a MIG reply.
    public enum ParseError: Swift.Error {
        /// The reply size was not what was expected
        case unexpectedReplySize(
            expectedSize: mach_msg_size_t, actualSize: mach_msg_size_t
        )
        /// The reply complexity was not what was expected
        case unexpectedReplyComplexity(expectedComplexity: Bool, actualComplexity: Bool)
    }
    /// The base routine ID for the MIG server.
    let baseRoutineId: mach_msg_id_t

    /// Create a new MIG connection with a given service name and base routine ID.
    /// - Parameters:
    ///   - serviceName: The service name to connect to.
    ///   - baseRoutineId: The base routine ID for the MIG server.
    public init(
        serviceName: String, baseRoutineId: mach_msg_id_t
    ) throws {
        self.baseRoutineId = baseRoutineId
        try super.init(serviceName: serviceName)
    }

    /// Create a new MIG connection with a given port and base routine ID.
    /// - Parameters:
    ///   - port: The port to connect to.
    ///   - baseRoutineId: The base routine ID for the MIG server.
    public init(
        port: mach_port_t, baseRoutineId: mach_msg_id_t
    ) {
        self.baseRoutineId = baseRoutineId
        super.init(port: port)
    }

    /// Perform sanity checks on a MIG reply.
    /// - Parameters:
    ///   - reply: The potential reply to check.
    ///   - routineId: The routine ID that was called.
    private static func checkReply<ReplyPayload>(
        _ reply: MIGReply<ReplyPayload>, routineId: mach_msg_id_t, expectedComplexity: Bool
    ) throws {
        // sanity checks (use locally defined error codes)
        guard reply.id != MACH_NOTIFY_SEND_ONCE else { throw MIGError(.serverDied) }  // server deallocated the send-once right without using it, assume it died
        guard reply.id == routineId + 100 else { throw MIGError(.replyMismatch) }  // the reply ID should be the request ID + 100
        guard reply.remotePort.port == MACH_PORT_NULL else { throw MIGError(.typeError) }  // the reply should clear the remote port
        let errorReply = MIGErrorReply()  // create a temporary error reply to check the reply against
        if !reply.isComplex && reply.size == errorReply.messageSize {
            try! errorReply.copyIn(from: reply)  // the reply is probably an error, so copy it into the error reply
            // If the return code is KERN_SUCCESS, then we should not actually throw (it's probably just an empty reply)
            guard errorReply.payload?.returnCode != KERN_SUCCESS else { return }
            throw errorReply.error
        }
        // Most of the time, a MIG reply is complex, but we do want to support non-complex replies
        guard reply.isComplex == expectedComplexity else {
            throw ParseError.unexpectedReplyComplexity(
                expectedComplexity: expectedComplexity, actualComplexity: errorReply.isComplex
            )
        }
    }

    /// Perform a MIG routine.
    /// - Parameters:
    ///   - routineIndex: The index of the routine to perform (offset from the base routine ID).
    ///   - requestOptions: The options for the request.
    ///   - replyOptions: The options for the reply.
    public func doRoutine<RequestPayload, ReplyPayload>(
        _ routineIndex: mach_msg_id_t,
        request: Request<RequestPayload>,
        // default to an error reply, but allow for a custom reply
        reply: Reply<ReplyPayload> = MIGErrorReply(),
        machMsgOptions: MachMsgOptions = []
    ) throws {
        // The actual routine ID's are often very large numbers, which can be unweildy to work
        // with. In order to simplify, we represent each routine as their offset from the base
        // routine ID. This makes the numbers much smaller and easier to work with.
        let routineId = self.baseRoutineId + routineIndex

        // build the request and reply
        request.id = routineId
        request.migRemotePort = self.connectionPort

        try MachMessaging.sendAndReceive(
            request,
            receiveMessage: reply,
            options: machMsgOptions
        )

        // we don't know if the reply is what we expect, so we need to check it
        try Self.checkReply(
            reply, routineId: routineId,
            // while descriptors and the complexity bit can be set independently, we expect them to be set together
            expectedComplexity: reply.descriptors != nil
        )
        // `reply` is typed based on what we *expect* the reply to be, so `messageSize` is also merely expected
        let expectedSize = reply.messageSize
        // the advertised size in the header is the *actual* size of the message data
        let actualSize = reply.size

        // confirm the advertised size of the reply is what we expect
        guard actualSize == expectedSize else {
            throw ParseError.unexpectedReplySize(expectedSize: expectedSize, actualSize: actualSize)
        }
    }
}
