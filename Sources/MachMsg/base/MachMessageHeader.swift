import CCompat
import Darwin

private let MACH_MSGH_BITS_PORTS_MASK = mach_msg_type_name_t(
    MACH_MSGH_BITS_REMOTE_MASK | MACH_MSGH_BITS_LOCAL_MASK | MACH_MSGH_BITS_VOUCHER_MASK)

/// A class representing the header of a Mach message.
public class MachMessageHeader {

    /// A struct representing the configuration bits for the message.
    public struct Bits: RawRepresentable {
        public typealias RawValue = mach_msg_bits_t

        /// Initialize a new configuration bits struct.
        /// - Parameter rawValue: The bits to initialize with.
        public init?(rawValue: RawValue) {
            self.init(bits: rawValue)
        }

        /// The raw value of the configuration bits.
        public var rawValue: RawValue {
            get { self._remote | self._local << 8 | self._voucher << 16 | self._other }
            set { self = .init(bits: newValue) }
        }

        private var _remote: mach_msg_type_name_t
        private var _local: mach_msg_type_name_t
        private var _voucher: mach_msg_type_name_t
        private var _other: mach_msg_type_name_t

        /// The remote port disposition.
        var remote: mach_msg_type_name_t {
            get { self._remote & mach_msg_type_name_t(MACH_MSGH_BITS_REMOTE_MASK) }
            set { self._remote = newValue & mach_msg_type_name_t(MACH_MSGH_BITS_REMOTE_MASK) }
        }
        /// The local port disposition.
        var local: mach_msg_type_name_t {
            get { self._local & mach_msg_type_name_t(MACH_MSGH_BITS_LOCAL_MASK >> 8) }
            set {
                self._local = newValue & mach_msg_type_name_t(MACH_MSGH_BITS_LOCAL_MASK >> 8)
            }
        }
        /// The voucher disposition.
        var voucher: mach_msg_type_name_t {
            get { self._voucher & mach_msg_type_name_t(MACH_MSGH_BITS_VOUCHER_MASK >> 16) }
            set {
                self._voucher =
                    newValue & mach_msg_type_name_t(MACH_MSGH_BITS_VOUCHER_MASK >> 16)
            }
        }
        /// The other flags.
        var other: mach_msg_type_name_t {
            get { self._other & mach_msg_type_name_t(~MACH_MSGH_BITS_PORTS_MASK) }
            set { self._other = newValue & mach_msg_type_name_t(~MACH_MSGH_BITS_PORTS_MASK) }
        }

        /// Initialize a new configuration bits struct.
        init() {
            self.init(remote: 0, local: 0, voucher: 0, other: 0)
        }
        /// Initialize a new configuration bits struct.
        /// - Parameter bits: The bits to initialize with.
        init(bits: mach_msg_bits_t) {
            self.init(
                remote: bits & mach_msg_type_name_t(MACH_MSGH_BITS_REMOTE_MASK),
                local: (bits & mach_msg_type_name_t(MACH_MSGH_BITS_LOCAL_MASK)) >> 8,
                voucher: (bits & mach_msg_type_name_t(MACH_MSGH_BITS_VOUCHER_MASK)) >> 16,
                other: mach_msg_type_name_t(bits & ~MACH_MSGH_BITS_PORTS_MASK)
            )
        }
        /// Initialize a new configuration bits struct.
        /// - Parameters:
        ///   - remote: The remote port disposition.
        ///   - local: The local port disposition.
        ///   - voucher: The voucher disposition.
        ///   - other: The other flags.
        init(
            remote: mach_msg_type_name_t, local: mach_msg_type_name_t,
            voucher: mach_msg_type_name_t, other: mach_msg_type_name_t
        ) {
            self._remote = remote & mach_msg_type_name_t(MACH_MSGH_BITS_REMOTE_MASK)
            self._local = local & mach_msg_type_name_t(MACH_MSGH_BITS_LOCAL_MASK >> 8)
            self._voucher = voucher & mach_msg_type_name_t(MACH_MSGH_BITS_VOUCHER_MASK >> 16)
            self._other = other & mach_msg_type_name_t(~MACH_MSGH_BITS_PORTS_MASK)
        }
    }

    /// The pointer to the mach_msg_header_t struct.
    let pointer: UnsafeMutablePointer<mach_msg_header_t>

    /// Operate on the message header with an unsafe mutable pointer.
    /// - Parameter body: The closure to execute.
    /// - Returns: The result of the closure.
    /// - Throws: Any error thrown by the closure.
    /// - Warning: The pointer must not be deallocated while the closure is executing.
    /// - Warning: Only use this method if you know what you are doing.
    public func withUnsafeMutablePointer<T>(
        _ body: (UnsafeMutablePointer<mach_msg_header_t>) throws -> T
    ) rethrows -> T {
        try body(UnsafeMutablePointer(self.pointer))
    }

    /// The configuration bits for the message.
    public var bits: Bits {
        get { Bits(bits: self.pointer.pointee.msgh_bits) }
        set { self.pointer.pointee.msgh_bits = newValue.rawValue }
    }

    /// The size of the received message data in bytes. It is 0 for sent messages.
    /// - Remark: This excludes any alignment padding between the payload and the trailer and the trailer itself.
    public var messageSize: mach_msg_size_t {
        self.pointer.pointee.msgh_size
    }

    /// The port right being sent to.
    public var remotePort: MachPort {
        get {
            MachPort(
                port: self.pointer.pointee.msgh_remote_port,
                disposition: .init(rawValue: self.bits.remote) ?? .unknown)
        }
        set {
            self.pointer.pointee.msgh_remote_port = newValue.port
            self.bits.remote = newValue.disposition.rawValue
        }
    }

    /// The port right being sent from.
    public var localPort: MachPort {
        get {
            MachPort(
                port: self.pointer.pointee.msgh_local_port,
                disposition: .init(rawValue: self.bits.local) ?? .unknown)
        }
        set {
            self.pointer.pointee.msgh_local_port = newValue.port
            self.bits.local = newValue.disposition.rawValue
        }
    }

    /// The voucher port.
    public var voucherPort: MachPort {
        get {
            MachPort(
                port: self.pointer.pointee.msgh_voucher_port,
                disposition: .init(rawValue: self.bits.voucher) ?? .unknown)
        }
        set {
            self.pointer.pointee.msgh_voucher_port = newValue.port
            self.bits.voucher = newValue.disposition.rawValue
        }
    }

    /// The user-defined message ID.
    public var messageID: mach_msg_id_t {
        get { self.pointer.pointee.msgh_id }
        set { self.pointer.pointee.msgh_id = newValue }
    }

    /// Initializes a new Mach message header.
    /// - Parameter pointer: The pointer to the mach_msg_header_t struct.
    /// - Warning: The pointer must be deallocated manually by the caller.
    init(
        pointer: UnsafeMutablePointer<mach_msg_header_t>
    ) {
        self.pointer = pointer
        self.pointer.initialize(repeating: mach_msg_header_t(), count: 1)
    }
}
