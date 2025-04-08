import Foundation
import KassC.SyscallBridge

extension BSD {
    /// Makes a system call with no arguments.
    public static func syscall(_ number: Int32) throws -> Int32 {
        try syscall(number, args: syscall_arg_t())
    }
    /// Makes a system call.
    public static func syscall(_ number: Int32, args: syscall_arg_t...) throws -> Int32 {
        // System calls can take up to 8 arguments.
        // https://github.com/apple-oss-distributions/xnu/blob/xnu-11215.81.4/bsd/sys/user.h#L125
        guard args.count <= 8 else { throw POSIXError(.E2BIG) }
        return try BSDCore.BSD.call(
            {
                switch args.count {
                case 0: syscall0(Int64(number))
                case 1: syscall1(Int64(number), args[0])
                case 2: syscall2(Int64(number), args[0], args[1])
                case 3: syscall3(Int64(number), args[0], args[1], args[2])
                case 4: syscall4(Int64(number), args[0], args[1], args[2], args[3])
                case 5: syscall5(Int64(number), args[0], args[1], args[2], args[3], args[4])
                case 6:
                    syscall6(Int64(number), args[0], args[1], args[2], args[3], args[4], args[5])
                case 7:
                    syscall7(
                        Int64(number), args[0], args[1], args[2], args[3], args[4], args[5], args[6]
                    )
                case 8:
                    syscall8(
                        Int64(number),
                        args[0], args[1], args[2], args[3],
                        args[4], args[5], args[6], args[7]
                    )
                // This should never happen, but just in case.
                default: throw POSIXError(.EINVAL)
                }
            }()
        )
    }
}
