import Darwin.Mach

extension Mach {
    public typealias FlavoredDataManagerNoAdditionalArgs<Flavor, ArrayPointee> =
        FlavoredDataManager<
            Flavor, ArrayPointee, Never?, Never?
        >
    open class FlavoredDataManager<
        Flavor, ArrayPointee,
        AdditionalGetterArgs: ExpressibleByNilLiteral,
        AdditionalSetterArgs: ExpressibleByNilLiteral
    > {
        public typealias Getter = (
            Flavor, UnsafeMutablePointer<ArrayPointee>,
            inout mach_msg_type_number_t,
            AdditionalGetterArgs
        ) -> kern_return_t
        public typealias Setter = (
            Flavor, UnsafeMutablePointer<ArrayPointee>,
            mach_msg_type_number_t,
            AdditionalSetterArgs
        ) -> kern_return_t

        var getter: Getter
        var setter: Setter
        public required init(getter: @escaping Getter, setter: @escaping Setter) {
            self.getter = getter
            self.setter = setter
        }

        /// Get flavored data.
        /// - Parameters:
        ///   - flavor: The flavor of the data.
        ///   - type: The type to load the data as.
        ///   - additional: Additional arguments to pass to the getter.
        /// - Throws: An error if the data cannot be retrieved.
        open func get<DataType>(
            _ flavor: Flavor, as type: DataType.Type,
            additional: AdditionalGetterArgs = nil
        ) throws -> DataType {
            try Mach.CallWithCountInOut(
                arrayType: UnsafeMutablePointer<ArrayPointee>.self, dataType: DataType.self,
                call: {
                    array, count in
                    getter(flavor, array, &count, additional)
                }
            )
        }
        /// Set flavored data.
        /// - Parameters:
        ///   - flavor: The flavor of the data.
        ///   - value: The value to set the data to.
        ///   - additional: Additional arguments to pass to the setter.
        /// - Throws: An error if the data cannot be set.
        open func set<DataType>(
            _ flavor: Flavor, to value: consuming DataType,
            additional: AdditionalSetterArgs = nil
        ) throws {
            try Mach.CallWithCountIn(
                arrayType: UnsafeMutablePointer<ArrayPointee>.self, data: value,
                call: {
                    array, count in
                    setter(flavor, array, count, additional)
                }
            )
        }
    }
}