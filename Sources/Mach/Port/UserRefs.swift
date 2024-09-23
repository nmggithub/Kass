import Darwin.Mach

extension Mach.Port {
    /// A count of user references to a port right.
    public struct UserRefs {
        /// The port the right is to.
        public let port: Mach.Port

        /// The port right the user references are to.
        public let right: Right

        /// The count of user references.
        public var count: Int {
            get throws {
                var refs = mach_port_urefs_t()
                try Mach.call(
                    mach_port_get_refs(
                        self.port.owningTask.name, self.port.name, self.right.rawValue, &refs
                    )
                )
                return Int(refs)
            }
        }

        /// Increments the count of user references.
        /// - Parameters:
        ///   - refs: The user references.
        ///   - delta: The amount to increment by.
        /// - Throws: If the count of user references cannot be incremented.
        public static func += (refs: UserRefs, delta: mach_port_delta_t) throws {
            try Mach.call(
                mach_port_mod_refs(
                    refs.port.owningTask.name, refs.port.name, refs.right.rawValue, delta
                )
            )
        }

        /// Decrements the count of user references.
        /// - Parameters:
        ///   - refs: The user references.
        ///   - delta: The amount to decrement by.
        /// - Throws: If the count of user references cannot be decremented.
        public static func -= (refs: UserRefs, delta: mach_port_delta_t) throws {
            try Mach.call(
                mach_port_mod_refs(
                    refs.port.owningTask.name, refs.port.name, refs.right.rawValue, -delta
                )
            )
        }

        /// Compares the count of user references to a given count.
        /// - Parameters:
        ///   - lhs: The user references.
        ///   - rhs: The count to compare to.
        /// - Throws: If the count of user references cannot be compared.
        /// - Returns: Whether the count of user references is equal to the given count.
        public static func == (lhs: UserRefs, rhs: Int) throws -> Bool {
            try lhs.count == mach_port_urefs_t(rhs)
        }

        /// Compares a given count to the count of user references.
        /// - Parameters:
        ///   - lhs: The count to compare to.
        ///   - rhs: The user references.
        /// - Throws: If the count of user references cannot be compared.
        /// - Returns: Whether the count of user references is equal to the given count.
        public static func == (lhs: Int, rhs: UserRefs) throws -> Bool {
            try mach_port_urefs_t(lhs) == rhs.count
        }
    }

    /// Gets the count of user references to the port right.
    /// - Parameter right: The right to the port.
    /// - Returns: The count of user references to the port right.
    public func userRefs(for right: Right) -> UserRefs { UserRefs(port: self, right: right) }
}
