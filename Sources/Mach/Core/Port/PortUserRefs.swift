import Darwin

extension Mach.Port {
    /// A user reference count for a port right.
    public struct UserRefs {
        /// The port the right is to.
        internal let port: Mach.Port

        /// The port right the user reference count is for.
        internal let right: Mach.PortRight

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
        public static func += (refs: UserRefs, delta: mach_port_delta_t) throws {
            try Mach.call(
                mach_port_mod_refs(
                    refs.port.owningTask.name, refs.port.name, refs.right.rawValue, delta
                )
            )
        }

        /// Decrements the user reference count.
        public static func -= (refs: UserRefs, delta: mach_port_delta_t) throws {
            try refs += -delta
        }

        /// Compares the user reference count to a given count.
        public static func == (lhs: UserRefs, rhs: Int) throws -> Bool {
            try lhs.count == mach_port_urefs_t(rhs)
        }

        /// Compares a given count to the user reference count.
        public static func == (lhs: Int, rhs: UserRefs) throws -> Bool {
            try mach_port_urefs_t(lhs) == rhs.count
        }
    }

    /// Gets the user reference count for the port right.
    public func userRefs(for right: Mach.PortRight) -> UserRefs {
        UserRefs(port: self, right: right)
    }

    /// Sets the user reference count for the port right.
    /// - Warning: This function is not atomic.
    public func setUserRefs(for right: Mach.PortRight, to count: Int) throws {
        let refs = userRefs(for: right)
        let delta = mach_port_delta_t(count) - mach_port_delta_t(try refs.count)
        if delta > 0 { try refs += delta } else if delta < 0 { try refs -= -delta }
    }
}
