#if canImport(IOKit)

    import IOKit
    import MachCore

    extension OS {
        /// A plug-in interface (really a pointer to a pointer to an interface structure).
        public typealias IOCFPlugInInterface =
            UnsafeMutablePointer<UnsafeMutablePointer<IOCFPlugInInterfaceStruct>?>
    }

    extension OS.IOCFPlugInInterface {
        /// Returns the specified method in the plug-in interface so it can be called.
        /// - Note: This is mainly to avoid having to use `pointee.pointee` everywhere.
        /// - Warning: Only use this function to get methods, not properties.
        /// - Warning: Immediately call the returned function. Do not store it for later.
        public func call<Path>(_ keyPath: KeyPath<IOCFPlugInInterfaceStruct, Path>) -> Path {
            self.pointee!.pointee[keyPath: keyPath]
        }

        /// Destroys the plug-in interface.
        public func destroy() throws {
            try Mach.call(IODestroyPlugInInterface(self))
        }
    }

    extension OS.IOService {
        /// Creates a plug-in interface for the specified service, returning the interface and a score.
        public func createPlugInInterface(
            pluginType: CFUUID,
            interfaceType: CFUUID
        ) throws -> (interface: OS.IOCFPlugInInterface, score: Int32) {
            var pluginInterface: OS.IOCFPlugInInterface?
            var score: Int32 = 0
            try Mach.call(
                IOCreatePlugInInterfaceForService(
                    self.name,
                    pluginType,
                    interfaceType,
                    &pluginInterface,
                    &score
                ))
            return (interface: pluginInterface!, score: score)
        }
    }

#endif  // canImport(IOKit)
