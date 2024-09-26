import Foundation

extension Mach.Task {
    /// Gets the data of a kernelcache object.
    public func kernelcacheData<DataType>(
        of kcObject: Mach.Port, as type: DataType.Type
    ) throws -> DataType {
        let data = try self.kernelcacheData(of: kcObject)
        return data.withUnsafeBytes { buffer in
            buffer.load(as: DataType.self)
        }
    }

    /// Gets the data of a kernelcache object.
    public func kernelcacheData(of kcObject: Mach.Port) throws -> Data {
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
