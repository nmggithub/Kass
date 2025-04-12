import Darwin.Mach
import Foundation

extension Mach {
    /// An error reply payload for a MIG routine.
    private struct MIGErrorReplyPayload: Mach.MIGPayloadWithNDR {
        let NDR = NDR_record_t()
        var returnCode: kern_return_t
    }

    /// A handler for a MIG server routine.
    public struct MIGServerRoutineHandler {
        /// The handler with untyped messages.
        let untypedHandler: (Mach.Message) throws -> Mach.Message

        /// Initializes a new routine handler.
        public init<RequestPayload: Mach.MIGPayload, ReplyPayload: Mach.MIGPayload>(
            expectingDescriptorTypes: [any Mach.MessageDescriptor.Type]? = nil,
            expectingAdditionalPredicate:
                ((Mach.MIGRequest<RequestPayload>) -> Bool)? = nil,
            _ typedHandler:
                @escaping (Mach.MIGRequest<RequestPayload>) throws -> Mach.MIGReply<ReplyPayload>
        ) {
            self.untypedHandler = { incomingMessage in
                let typedMessage = Mach.MIGRequest<RequestPayload>.init(
                    headerPointer: incomingMessage.serialize()
                )
                guard
                    // If the payload type is not Never, it should have been recovered
                    //  from the above initializer. If it is Never, it should be nil.
                    ((RequestPayload.self != Never.self) == (typedMessage.typedPayload != nil))
                        // We need to check if the descriptors are of the expected types.
                        && (typedMessage.body?.descriptors.enumerated()
                            .allSatisfy {
                                index, descriptor in
                                type(of: descriptor) == expectingDescriptorTypes?[index]
                            }
                            // If we're short-circuiting here, there were no descriptors, so we
                            //  now need to check if that's what we were expecting.
                            ?? (expectingDescriptorTypes == nil))
                        // We need to check if the additional predicate is satisfied.
                        && ((expectingAdditionalPredicate?(typedMessage) ?? true) == true)

                else {
                    // If any of the above checks fail, we tell the
                    //  client that their arguments were invalid.
                    return Mach.MIGReply(
                        payload: Mach.MIGErrorReplyPayload(returnCode: MIG_BAD_ARGUMENTS)
                    )

                }
                return try typedHandler(typedMessage)
            }
        }
    }

    /// A server for MIG requests.
    open class MIGServer: Mach.Port {
        /// The base routine ID for the local MIG subsystem.
        open var baseRoutineID: mach_msg_id_t

        /// The handlers for the routines.
        /// - Important: These should be ordered by the routine ID.
        open var routinesHandlers: [MIGServerRoutineHandler?]

        /// Represents an existing MIG server port.
        public required init(
            named name: mach_port_name_t, baseRoutineID: mach_msg_id_t,
            routinesHandlers: [MIGServerRoutineHandler?] = []
        ) {
            self.routinesHandlers = routinesHandlers
            self.baseRoutineID = baseRoutineID
            super.init(named: name)
        }

        @available(*, unavailable, message: "Use `init(named:baseRoutineID:)` instead.")
        public required init(named name: mach_port_name_t, inNameSpaceOf task: Mach.Task = .current)
        {
            self.routinesHandlers = []
            self.baseRoutineID = 0
            super.init(named: name)
        }

        /// Gets the reply for an incoming message.
        private func getReplyFor(incomingMessage: Mach.Message) -> Mach.Message {
            let routineIndex = incomingMessage.header.msgh_id - self.baseRoutineID
            guard
                self.routinesHandlers.indices.contains(Int(routineIndex)),
                let routineHandler = self.routinesHandlers[Int(routineIndex)]
            else {
                // If we don't have a handler for the routine, we tell
                //  the client that their routine ID was invalid.
                return Mach.MIGReply(payload: MIGErrorReplyPayload(returnCode: MIG_BAD_ID))
            }
            do { return try routineHandler.untypedHandler(incomingMessage) } catch {
                let errorCode = (error as NSError).code
                return Mach.MIGReply(payload: MIGErrorReplyPayload(returnCode: Int32(errorCode)))
            }
        }

        /// Replies to an incoming message.
        private func replyTo(incomingMessage: Mach.Message) throws {
            let replyMessage = self.getReplyFor(incomingMessage: incomingMessage)
            replyMessage.header.msgh_id = incomingMessage.header.msgh_id + 100
            try Mach.Message.send(
                replyMessage,
                // We send the reply message to the port that sent the request.
                to: incomingMessage.header.remotePort,
                // We move back our send-once right to the sender.
                withDisposition: .moveSendOnce
            )
        }

        /// A thread that listens for incoming messages and replies to them.
        private class MIGServerThread: Foundation.Thread {
            /// The server to listen for.
            private let server: Mach.MIGServer

            /// The error handler to call on errors.
            private let errorHandler: ((Error) -> Void)?

            /// Initializes the server thread.
            init(server: Mach.MIGServer, errorHandler: ((Error) -> Void)?) {
                self.server = server
                self.errorHandler = errorHandler
            }

            /// Listens for incoming messages and replies to them.
            override func main() {
                while true {
                    do {
                        print("Waiting for incoming message...")
                        let incomingMessage = try Mach.Message.receive(from: server)
                        print("Got incoming message: \(incomingMessage)")
                        try server.replyTo(incomingMessage: incomingMessage)
                    } catch { errorHandler?(error) }
                }
            }
        }

        /// Starts listening for incoming messages and returns the listener thread.
        /// - Important: Errors passed to the handler may originate in either
        ///      the receiving of a message or the sending of a reply.
        public func startListening(_ errorHandler: ((Error) -> Void)? = nil) -> Foundation.Thread {
            let listenerThread = MIGServerThread(
                server: self,
                errorHandler: errorHandler
            )
            listenerThread.start()
            return listenerThread
        }
    }
}

extension Mach.ServerInitializableByServiceName where Self: Mach.MIGServer {
    /// Registers a MIG server for the given service name.
    public init(serviceName: String, baseRoutineID: mach_msg_id_t) throws {
        try self.init(serviceName: serviceName)
        self.baseRoutineID = baseRoutineID
    }
}
