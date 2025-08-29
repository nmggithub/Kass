import CoreFoundation.CFPlugInCOM
import KassHelpers

extension OS {
    /// COM-related functionality.
    public struct COM: KassHelpers.Namespace {
        /// A return value for a COM operation.
        public struct HResult: RawRepresentable, Sendable {
            /// The raw HRESULT value.
            public var rawValue: HRESULT

            /// Represents a raw HRESULT value.
            public init(rawValue: HRESULT) {
                self.rawValue = rawValue
            }

            /// If the operation succeeded.
            // Based on the SUCCEEDED macro.
            public var succeeded: Bool { return rawValue >= 0 }

            /// If the operation failed.
            // Based on the FAILED macro.
            public var failed: Bool { return rawValue < 0 }

            /// If the operation resulted in an error.
            /// - Warning: While this is basically equivalent to `failed`, it is
            ///     advised to use `failed` over this for canonical purposes.
            // Based on the IS_ERROR macro.
            public var isError: Bool { return severity == SEVERITY_ERROR }

            /// The code.
            // Based on the HRESULT_CODE macro.
            public var code: Int32 { rawValue & 0xFFFF }

            /// The facility.
            // Based on the HRESULT_FACILITY macro.
            public var facility: Int32 { (rawValue >> 16) & 0x1FFF }

            /// The severity.
            // Based on the HRESULT_SEVERITY macro.
            public var severity: Int32 { (rawValue >> 31) & 0x1 }

            /// Represents an HRESULT by its component parts.
            // Based on the MAKE_HRESULT macro.
            public init(severity: Int32, facility: Int32, code: Int32) {
                self.rawValue = (severity << 31) | (facility << 16) | (code & 0xFFFF)
            }
        }

        /// An error result from a COM operation.
        public struct COMError: Error {
            /// The underlying HRESULT value.
            public var hresult: HResult

            /// Represents the error associated with the HRESULT, if one exists.
            public init?(hresult: HResult) {
                guard hresult.failed else { return nil }
                self.hresult = hresult
            }
        }

        /// A protocol for a IUnknown vtable.
        // This is just the IUnknownVtbl struct as a Swift protocol. We redefine
        //  it here to make working with IUnknown vtables easier.
        public protocol IUnknownVTblProtocol {
            var _reserved: UnsafeMutableRawPointer! { get }
            var QueryInterface:
                (
                    @convention(c) (
                        UnsafeMutableRawPointer?, REFIID, UnsafeMutablePointer<LPVOID?>?
                    ) ->
                        HRESULT
                )!
            { get }
            var AddRef: (@convention(c) (UnsafeMutableRawPointer?) -> ULONG)! { get }
            var Release: (@convention(c) (UnsafeMutableRawPointer?) -> ULONG)! { get }
        }

        /// A pointer for a COM interface (really a pointer to a pointer to an vtable structure).
        public typealias COMInterfacePointer<VTable: IUnknownVTblProtocol> =
            UnsafeMutablePointer<UnsafeMutablePointer<VTable>?>

        /// A COM interface.
        public protocol COMInterface {
            /// The type of the interface's vtable,
            associatedtype VTable: IUnknownVTblProtocol

            /// The pointer to the interface.
            var pointer: COMInterfacePointer<VTable> { get }

            /// The UUID for the interface.
            static var interfaceID: CFUUID { get }

            /// The vtable for the interface.
            var vtable: VTable { get }

            /// Represents the interface pointed to by the pointer.
            init(voidPointer: LPVOID)

            /// Represents the interface pointed to by the pointer.
            init(pointer: COMInterfacePointer<VTable>)
        }
    }
}

extension OS.COM.COMInterface {
    public var vtable: VTable {
        self.pointer.pointee!.pointee
    }

    public init(voidPointer: LPVOID) {
        self.init(
            pointer: voidPointer.assumingMemoryBound(
                to: OS.COM.COMInterfacePointer<VTable>.Pointee.self
            )
        )
    }
}

/// Makes the IUnknownVtbl struct conform to IUnknownVTblProtocol.
extension IUnknownVTbl: OS.COM.IUnknownVTblProtocol {}

extension OS.COM {
    /// An unknown COM interface.
    public struct IUnknownCOMInterface: OS.COM.COMInterface {
        public static var interfaceID: CFUUID {
            // This is defined as macro in the original SDK. That macro
            //  can't be used in Swift, so we redefine the value here.
            CFUUIDGetConstantUUIDWithBytes(
                kCFAllocatorSystemDefault,
                0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
                0xC0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x46
            )!
        }

        public let pointer: OS.COM.COMInterfacePointer<IUnknownVTbl>

        public init(pointer: OS.COM.COMInterfacePointer<IUnknownVTbl>) {
            self.pointer = pointer
        }
    }
}

/// Wraps the members of the COM interface's vtable.
extension OS.COM.COMInterface {
    /// Executes a function that returns a HRESULT and throws an error if it fails.
    public static func call(
        _ call: @autoclosure () throws -> HRESULT
    ) throws {
        let hr = try call()
        if let error = OS.COM.COMError(hresult: OS.COM.HResult(rawValue: hr)) {
            throw error
        }
    }
    /// Queries for an interface and returns a pointer to it.
    public func QueryInterface<QueriedInterface: OS.COM.COMInterface>(
        uuid: CFUUID = QueriedInterface.interfaceID,
        interfaceType: QueriedInterface.Type = QueriedInterface.self
    ) throws -> QueriedInterface {
        var result: LPVOID?
        try Self.call(
            self.vtable.QueryInterface(
                self.pointer,
                CFUUIDGetUUIDBytes(uuid),
                &result
            )
        )
        return QueriedInterface(voidPointer: result!)
    }

    /// Increments the reference count for the object and returns the new count.
    public func AddRef() -> ULONG {
        self.vtable.AddRef(self.pointer)
    }

    /// Decrements the reference count for the object and returns the new count.
    public func Release() -> ULONG {
        self.vtable.Release(self.pointer)
    }
}
