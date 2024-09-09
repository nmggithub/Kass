import Darwin.Mach

extension Mach.Port {
    /// The number of user references to a port right.
    public struct UserRefs {
        /// The port.
        internal let port: Mach.Port
        /// The right to the port.
        public let right: Right
        /// The number of user references to the port right.
        public var value: mach_port_urefs_t {
            get throws {
                var refs = mach_port_urefs_t()
                try Mach.Syscall(
                    mach_port_get_refs(
                        self.port.owningTask.name, self.port.name, self.right.rawValue, &refs
                    )
                )
                return refs
            }
        }
        /// Increment the number of user references to the port right.
        /// - Parameters:
        ///   - refs: The user references.
        ///   - delta: The amount to increment by.
        /// - Throws: If the number of user references cannot be incremented.
        public static func += (refs: UserRefs, delta: mach_port_delta_t) throws {
            try Mach.Syscall(
                mach_port_mod_refs(
                    refs.port.owningTask.name, refs.port.name, refs.right.rawValue, delta
                )
            )
        }
        /// Decrement the number of user references to the port right.
        /// - Parameters:
        ///   - refs: The user references.
        ///   - delta: The amount to decrement by.
        /// - Throws: If the number of user references cannot be decremented.
        public static func -= (refs: UserRefs, delta: mach_port_delta_t) throws {
            try Mach.Syscall(
                mach_port_mod_refs(
                    refs.port.owningTask.name, refs.port.name, refs.right.rawValue, -delta
                )
            )
        }
    }
    /// Get the number of user references to the port right.
    /// - Parameter right: The right to the port.
    /// - Returns: The number of user references to the port right.
    public func userRefs(for right: Right) -> UserRefs {
        return UserRefs(port: self, right: right)
    }
}
