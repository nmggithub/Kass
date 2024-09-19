import Darwin.Mach

extension Mach.Message {
    /// A message trailer.
    public class Trailer: RawRepresentable {
        /// A trailer type.
        public struct TrailerType: RawRepresentable {
            /// The raw trailer type.
            public var rawValue: mach_msg_trailer_type_t {
                baseType.shiftedValue | elements.shiftedValue
            }
            /// Represent a trailer type with a raw value.
            /// - Parameter rawValue: The raw value of the trailer type.
            public init(rawValue: mach_msg_trailer_type_t) {
                self.baseType = BaseType(rawValue: (rawValue >> 28) & 0xf)!
                self.elements = Elements(rawValue: (rawValue >> 24) & 0xf)!
            }
            /// A base trailer type.
            public enum BaseType: mach_msg_trailer_type_t {
                case format0 = 0
                public var shiftedValue: mach_msg_trailer_type_t {
                    (self.rawValue & 0xf) << 28
                }
            }
            /// A trailer elements modifier.
            /// - Important: Each case represents a trailer with the given element and all elements of previous cases.
            public enum Elements: mach_msg_trailer_type_t {
                case null = 0
                case sequenceNumber = 1
                case sender = 2
                case audit = 3
                case context = 4
                // where are 5 and 6?
                case av = 7
                case labels = 8
                public var shiftedValue: mach_msg_trailer_type_t {
                    (self.rawValue & 0xf) << 24
                }
            }
            /// The base type of the trailer.
            public let baseType: BaseType
            /// The last element of the trailer.
            public let elements: Elements

            /// Represent a trailer type with a base type and elements.
            /// - Parameters:
            ///   - baseType: The base type of the trailer.
            ///   - elements: The last element of the trailer.
            public init(baseType: BaseType = .format0, elements: Elements) {
                self.baseType = baseType
                self.elements = elements
            }
        }
        /// The raw trailer.
        public var rawValue: mach_msg_max_trailer_t
        /// Represent an existing raw trailer.
        /// - Parameter rawValue: The raw trailer.
        public required init(rawValue: mach_msg_max_trailer_t) {
            self.rawValue = rawValue
        }
        /// The trailer type.
        public var type: TrailerType {
            TrailerType(rawValue: self.rawValue.msgh_trailer_type)
        }
        /// The size of the trailer.
        public var size: mach_msg_size_t {
            self.rawValue.msgh_trailer_size
        }
        /// The sequence number of the message, relative to the queue on which it was received.
        public var sequenceNumber: mach_port_seqno_t {
            self.rawValue.msgh_seqno
        }
        /// The security token of the task that sent the message.
        public var securityToken: security_token_t {
            self.rawValue.msgh_sender
        }
        /// The audit token of the task that sent the message.
        public var auditToken: audit_token_t {
            self.rawValue.msgh_audit
        }
        /// The context of the port that sent the message.
        public var context: mach_port_context_t {
            self.rawValue.msgh_context
        }
        /// The filter ID.
        public var filterId: mach_msg_filter_id {
            self.rawValue.msgh_ad
        }
        /// The labels.
        public var labels: msg_labels_t {
            self.rawValue.msgh_labels
        }
    }
}
