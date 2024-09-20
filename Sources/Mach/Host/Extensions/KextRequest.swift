import Darwin.Mach
import Foundation

extension Mach.Host {
    /// Performs a kext request.
    /// - Parameter request: The request data.
    /// - Throws: If the request fails.
    /// - Returns: The response data.
    /// - Warning: This always fails on secure kernels.
    public func kextRequest(_ request: Data) throws -> Data {
        let dataCopy = request.withUnsafeBytes {
            buffer in
            let bufferCopy = UnsafeMutableRawBufferPointer.allocate(
                byteCount: buffer.count, alignment: 1
            )
            bufferCopy.copyMemory(from: buffer)
            return bufferCopy
        }
        defer { dataCopy.deallocate() }
        var responseAddress = vm_offset_t()
        var responseCount = mach_msg_size_t()
        var actualReturn = kern_return_t()
        try Mach.call(
            kext_request(
                self.name,
                0,
                vm_offset_t(bitPattern: dataCopy.baseAddress),
                mach_msg_size_t(request.count),
                &responseAddress, &responseCount,
                nil, nil, &actualReturn
            )
        )
        try Mach.call(actualReturn)
        let response = Data(
            bytes: UnsafeRawPointer(bitPattern: responseAddress)!,
            count: Int(responseCount)
        )
        return response
    }
}
