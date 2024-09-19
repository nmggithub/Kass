import Foundation

extension Mach.Task {
    /// Get the data of a kernel cache object as a specific type.
    /// - Parameters:
    ///   - kcObject: The kernel cache object, represented as a port.
    ///   - type: The type to load the data as.
    /// - Throws: An error if the data cannot be retrieved.
    /// - Returns: The data of the kernel cache object.
    public func data<DataType>(
        of kcObject: Mach.Port, as type: DataType.Type
    ) throws -> DataType {
        let data = try self.data(of: kcObject)
        return data.withUnsafeBytes { buffer in
            buffer.load(as: DataType.self)
        }
    }

    /// Get the data of a kernel cache object.
    /// - Parameter kcObject: The kernel cache object, represented as a port.
    /// - Throws: An error if the data cannot be retrieved.
    /// - Returns: The data of the kernel cache object.
    public func data(of kcObject: Mach.Port) throws -> Data {
        var address = mach_vm_address_t()
        var size = mach_vm_size_t()
        try Mach.call(
            task_map_kcdata_object_64(self.name, kcObject.name, &address, &size)
        )
        guard let addressPointer = UnsafeRawPointer(bitPattern: Int(address)) else {
            fatalError("`task_map_kcdata_object_64` returned a null pointer.")
        }
        return Data(
            bytes: addressPointer,
            count: Int(size)
        )
    }
}
