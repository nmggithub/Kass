import Darwin.Mach

extension Mach.Port {
    /// A user reference count for a port right.
    public struct UserRefs {
        /// The port the right is to.
        public let port: Mach.Port

        /// The port right the user reference count is for.
        public let right: Right

        /// The user reference count.
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

        /// Increments the user reference count.
        /// - Parameters:
        ///   - refs: The user references.
        ///   - delta: The amount to increment by.
        /// - Throws: If the user reference count cannot be incremented.
        public static func += (refs: UserRefs, delta: mach_port_delta_t) throws {
            try Mach.call(
                mach_port_mod_refs(
                    refs.port.owningTask.name, refs.port.name, refs.right.rawValue, delta
                )
            )
        }

        /// Decrements the user reference count.
        /// - Parameters:
        ///   - refs: The user references.
        ///   - delta: The amount to decrement by.
        /// - Throws: If the user reference count cannot be decremented.
        public static func -= (refs: UserRefs, delta: mach_port_delta_t) throws {
            try Mach.call(
                mach_port_mod_refs(
                    refs.port.owningTask.name, refs.port.name, refs.right.rawValue, -delta
                )
            )
        }

        /// Compares the user reference count to a given count.
        /// - Parameters:
        ///   - lhs: The user references.
        ///   - rhs: The count to compare to.
        /// - Throws: If the user reference count cannot be compared to the given count.
        /// - Returns: Whether the user reference count is equal to the given count.
        public static func == (lhs: UserRefs, rhs: Int) throws -> Bool {
            try lhs.count == mach_port_urefs_t(rhs)
        }

        /// Compares a given count to the user reference count.
        /// - Parameters:
        ///   - lhs: The count to compare to.
        ///   - rhs: The user references.
        /// - Throws: If the given count cannot be compared to the user reference count.
        /// - Returns: Whether the given count is equal to the user reference count.
        public static func == (lhs: Int, rhs: UserRefs) throws -> Bool {
            try mach_port_urefs_t(lhs) == rhs.count
        }
    }

    /// Gets the user reference count for the port right.
    /// - Parameter right: The port right to get the user reference count for.
    /// - Returns: The user reference count for the port right.
    public func userRefs(for right: Right) -> UserRefs { UserRefs(port: self, right: right) }

    /// Sets the user reference count for the port right.
    /// - Parameters:
    ///   - right: The port right to get the user reference count for.
    ///   - count: The value to set the user reference count to.
    /// - Throws: If the user reference count cannot be set.
    /// - Warning: This function is not atomic.
    public func setUserRefs(for right: Right, to count: Int) throws {
        let refs = userRefs(for: right)
        let delta = mach_port_delta_t(count) - mach_port_delta_t(try refs.count)
        if delta > 0 { try refs += delta } else if delta < 0 { try refs -= -delta }
    }
}
