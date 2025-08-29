#if canImport(IOKit)

    import IOKit
    import MachCore

    /// Makes IOCFPlugInInterfaceStruct conform to IUnknownVTblProtocol.
    extension IOCFPlugInInterfaceStruct: OS.COM.IUnknownVTblProtocol {}

    extension OS {
        /// A plug-in interface (really a pointer to a pointer to an interface structure).
        public struct IOCFPlugInCOMInterface: OS.COM.COMInterface {
            public var pointer: OS.COM.COMInterfacePointer<IOCFPlugInInterfaceStruct>
            public static var interfaceID: CFUUID {
                // This is defined as macro in the original SDK. That macro
                //  can't be used in Swift, so we redefine the value here.
                CFUUIDGetConstantUUIDWithBytes(
                    nil,
                    0xC2, 0x44, 0xE8, 0x58, 0x10, 0x9C, 0x11, 0xD4,
                    0x91, 0xD4, 0x00, 0x50, 0xE4, 0xC6, 0x42, 0x6F
                )
            }
        }
    }

    extension OS.IOCFPlugInCOMInterface {
        /// Destroys the plug-in interface.
        public func destroy() throws {
            try Mach.call(IODestroyPlugInInterface(self.pointer))
        }
    }

    extension OS.IOService {
        /// Creates a plug-in interface for the specified service, returning the interface and a score.
        public func createPlugInInterface(
            pluginType: CFUUID,
            interfaceType: CFUUID
        ) throws -> (interface: OS.IOCFPlugInCOMInterface, score: Int32) {
            var pluginInterfacePointer: OS.COM.COMInterfacePointer<IOCFPlugInInterfaceStruct>?
            var score: Int32 = 0
            try Mach.call(
                IOCreatePlugInInterfaceForService(
                    self.name,
                    pluginType,
                    interfaceType,
                    &pluginInterfacePointer,
                    &score
                ))
            let pluginInterface = OS.IOCFPlugInCOMInterface(pointer: pluginInterfacePointer!)
            return (interface: pluginInterface, score: score)
        }
    }

    /// Wraps the members of the plug-in interface's vtable.
    // First-party documentation on these members is barren, so the comments here are left intentionally vague.
    extension OS.IOCFPlugInCOMInterface {
        /// The version of the plug-in interface.
        public var version: UInt16 { self.vtable.version }

        /// The revision of the plug-in interface.
        public var revision: UInt16 { self.vtable.revision }

        /// Probes the plug-in interface.
        public func Probe(propertyTable: CFDictionary, service: OS.IOService) throws -> Int32 {
            var order: Int32 = 0
            try Mach.call(self.vtable.Probe(self.pointer, propertyTable, service.name, &order))
            return order
        }

        /// Starts the plug-in interface.
        public func Start(propertyTable: CFDictionary, service: OS.IOService) throws {
            try Mach.call(self.vtable.Start(self.pointer, propertyTable, service.name))
        }

        /// Stops the plug-in interface.
        public func Stop() throws {
            try Mach.call(self.vtable.Stop(self.pointer))
        }
    }
#endif  // canImport(IOKit)
