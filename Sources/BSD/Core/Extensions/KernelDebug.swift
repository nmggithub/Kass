import Darwin.POSIX
import Darwin.sys.kdebug
import Foundation
import KassC.KDebugPrivate
import KassHelpers

extension BSD {
    /// The kernel debugging system.
    public struct KernelDebug: Namespace {
        /// The kernel debugging typefilter.
        public static var typefilter: Data? {
            guard let typefilterPointer = kdebug_typefilter()
            else { return nil }
            return Data(
                bytes: typefilterPointer,
                count: Int(KDBG_TYPEFILTER_BITMAP_SIZE)
            )
        }

        // MARK: - Timestamps

        /// Returns if the kernel debugging system is using continuous time.
        @available(macOS 10.15, *)
        public static var usingContinuousTime: Bool {
            kdebug_using_continuous_time()
        }

        /// Returns the current timestamp from the kernel debugging system.
        @available(macOS 12, *)
        public static var timestamp: UInt64 {
            kdebug_timestamp()
        }

        /// Converts an absolute timestamp to a kernel debugging timestamp.
        @available(macOS 12, *)
        public static func timestampFromAbsolute(_ absoluteTime: UInt64) -> UInt64 {
            kdebug_timestamp_from_absolute(absoluteTime)
        }

        /// Converts a continuous timestamp to a kernel debugging timestamp.
        @available(macOS 12, *)
        public static func timestampFromContinuous(_ continuousTime: UInt64) -> UInt64 {
            kdebug_timestamp_from_continuous(continuousTime)
        }

        // MARK: - Tracing

        /// Returns if tracing is enabled for the given debug ID.
        public static func isTracingEnabled(_ debugID: UInt32) -> Bool {
            kdebug_is_enabled(debugID)
        }

        /// Calls `kdebug_trace` with the given arguments.
        public static func trace(_ debugID: UInt32, args: (UInt64, UInt64, UInt64, UInt64)) throws {
            try BSD.syscall(kdebug_trace(debugID, args.0, args.1, args.2, args.3))
        }

        /// Calls `kdebug_trace_string` with the given arguments.
        public static func trace(_ debugID: UInt32, stringID: UInt64 = 0, string: String) throws
            -> UInt64?
        {
            // The `kdebug_trace_string` function is documented to return the string ID (a generated
            // one if zero was passed in). `BSD.syscall` should handle any error return values.
            let result = try BSD.syscall(kdebug_trace_string(debugID, stringID, string))
            guard result != 0 else { return nil }  // No string ID was returned.
            return result
        }

        // MARK: - Signposts

        /// Calls `kdebug_signpost` with the given arguments.
        public static func signpost(_ code: UInt32, name: String, args: (UInt, UInt, UInt, UInt))
            throws
        {
            try BSD.syscall(kdebug_signpost(code, args.0, args.1, args.2, args.3))
        }

        /// Calls `kdebug_signpost_start` with the given arguments.
        public static func signpostStart(
            _ code: UInt32, name: String, args: (UInt, UInt, UInt, UInt)
        )
            throws
        {
            try BSD.syscall(kdebug_signpost_start(code, args.0, args.1, args.2, args.3))
        }

        /// Calls `kdebug_signpost_end` with the given arguments.
        public static func signpostEnd(
            _ code: UInt32, name: String, args: (UInt, UInt, UInt, UInt)
        )
            throws
        {
            try BSD.syscall(kdebug_signpost_end(code, args.0, args.1, args.2, args.3))
        }
    }
}
