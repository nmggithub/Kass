import Darwin.Mach

extension Mach {
    public class DefaultExceptionMessage: Mach.MIGReply<Mach.DefaultExceptionMessage.PayloadType> {
        /// An exception message payload.
        public struct PayloadType: Mach.MIGPayload, Mach.TrivialMessagePayload {
            public let NDR: NDR_record_t
            public let exceptionType: exception_type_t
            public let codeCount: mach_msg_type_number_t  // The size of the following `integer_t` "array". Should always be 2.
            public let code: integer_t
            public let subcode: integer_t
        }

        /// The exception type in the message.
        public var exceptionType: Mach.ExceptionType {
            Mach.ExceptionType(rawValue: self.typedPayload!.exceptionType)
        }

        /// The exception code in the message.
        public var code: integer_t {
            self.typedPayload!.code
        }

        /// The exception subcode in the message.
        public var subcode: integer_t {
            self.typedPayload!.subcode
        }

        /// The thread that the exception is for.
        public var thread: Mach.ThreadControl {
            Mach.ThreadControl(
                named: (self.body!.descriptors[0] as! mach_msg_port_descriptor_t).port.name
            )
        }

        /// The task that the exception is for.
        public var task: Mach.TaskControl {
            Mach.TaskControl(
                named: (self.body!.descriptors[1] as! mach_msg_port_descriptor_t).port.name
            )
        }
    }
}
