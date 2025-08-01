import Foundation
import KassC.SyscallBridge

extension BSD {
    /// An argument to a BSD system call.
    public protocol BSDSyscallArgument {
        func toSyscallArg() -> syscall_arg_t
    }

    /// Makes a system call with no arguments.
    public static func syscall(_ number: Int32) throws -> Int32 {
        try syscall(number, syscall_arg_t())
    }

    /// Makes a system call.
    public static func syscall(_ number: Int32, _ args: BSDSyscallArgument...) throws -> Int32 {
        // System calls can take up to 8 arguments.
        // https://github.com/apple-oss-distributions/xnu/blob/xnu-11215.81.4/bsd/sys/user.h#L125
        guard args.count <= 8 else { throw POSIXError(.E2BIG) }
        // Convert the arguments to syscall_arg_t.
        let arguments = args.map { $0.toSyscallArg() }
        return try BSDCore.BSD.call(
            {
                switch arguments.count {
                case 0: syscall0(number)
                case 1: syscall1(number, arguments[0])
                case 2: syscall2(number, arguments[0], arguments[1])
                case 3: syscall3(number, arguments[0], arguments[1], arguments[2])
                case 4: syscall4(number, arguments[0], arguments[1], arguments[2], arguments[3])
                case 5:
                    syscall5(
                        number, arguments[0], arguments[1],
                        arguments[2], arguments[3], arguments[4]
                    )
                case 6:
                    syscall6(
                        number, arguments[0], arguments[1], arguments[2],
                        arguments[3], arguments[4], arguments[5])
                case 7:
                    syscall7(
                        number, arguments[0], arguments[1], arguments[2],
                        arguments[3], arguments[4], arguments[5], arguments[6]
                    )
                case 8:
                    syscall8(
                        number,
                        arguments[0], arguments[1], arguments[2], arguments[3],
                        arguments[4], arguments[5], arguments[6], arguments[7]
                    )
                // This should never happen, but just in case.
                default: throw POSIXError(.EINVAL)
                }
            }()
        )
    }
}

// MARK: - BinaryInteger Extensions

extension BinaryInteger where Self: BSD.BSDSyscallArgument {
    public func toSyscallArg() -> syscall_arg_t { syscall_arg_t(self) }
}
extension Int: BSD.BSDSyscallArgument {}
extension UInt: BSD.BSDSyscallArgument {}
extension Int8: BSD.BSDSyscallArgument {}
extension UInt8: BSD.BSDSyscallArgument {}
extension Int16: BSD.BSDSyscallArgument {}
extension UInt16: BSD.BSDSyscallArgument {}
extension Int32: BSD.BSDSyscallArgument {}
extension UInt32: BSD.BSDSyscallArgument {}
extension Int64: BSD.BSDSyscallArgument {}
extension UInt64: BSD.BSDSyscallArgument {}
@available(macOS 15.0, iOS 18.0, *)
extension Int128: BSD.BSDSyscallArgument {}
@available(macOS 15.0, iOS 18.0, *)
extension UInt128: BSD.BSDSyscallArgument {}

// MARK: - Pointer Extensions

extension Swift._Pointer where Self: BSD.BSDSyscallArgument {
    public func toSyscallArg() -> syscall_arg_t {
        syscall_arg_t(UInt(bitPattern: self))
    }
}
extension UnsafePointer: BSD.BSDSyscallArgument {}
extension UnsafeMutablePointer: BSD.BSDSyscallArgument {}
extension UnsafeRawPointer: BSD.BSDSyscallArgument {}
extension UnsafeMutableRawPointer: BSD.BSDSyscallArgument {}

// MARK: - Other Extensions

extension String: BSD.BSDSyscallArgument {
    public func toSyscallArg() -> syscall_arg_t {
        let cString = self.withCString {
            let newPointer = UnsafeMutablePointer<CChar>.allocate(capacity: strlen($0) + 1)
            newPointer.initialize(from: $0, count: strlen($0) + 1)
            return newPointer
        }
        return syscall_arg_t(UInt(bitPattern: cString))
    }
}

extension Bool: BSD.BSDSyscallArgument {
    public func toSyscallArg() -> syscall_arg_t {
        syscall_arg_t(self ? 1 : 0)
    }
}

extension Data: BSD.BSDSyscallArgument {
    public func toSyscallArg() -> syscall_arg_t {
        self.withUnsafeBytes { originalBuffer in
            let newPointer = UnsafeMutableBufferPointer<UInt8>
                .allocate(capacity: originalBuffer.count)
            let _ = newPointer.initialize(from: originalBuffer)
            return syscall_arg_t(UInt(bitPattern: newPointer.baseAddress))
        }
    }
}

extension Array: BSD.BSDSyscallArgument {
    public func toSyscallArg() -> syscall_arg_t {
        self.withUnsafeBufferPointer { originalBuffer in
            let newPointer = UnsafeMutableBufferPointer<Element>
                .allocate(capacity: originalBuffer.count)
            let _ = newPointer.initialize(from: originalBuffer)
            return syscall_arg_t(UInt(bitPattern: newPointer.baseAddress))
        }
    }
}
