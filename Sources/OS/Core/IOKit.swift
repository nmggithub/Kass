import BSDCore
import Foundation
import IOKit
import MachCore
import System

extension OS {
    /// An object for IOKit.
    public class IOObject: MachCore.Mach.Port {
        /// A nil IOKit object.
        override public class var Nil: IOObject {
            return IOObject(named: IO_OBJECT_NULL)
        }
    }

    /// A main port for IOKit.
    /// - Note: This is called `IOKitMainPort` because the `IOMainPort` name
    ///     is already taken by the `IOKit` framework for a function.
    public class IOKitMainPort: MachCore.Mach.Port {

        /// Initializes a main port for IOKit using the given bootstrap port.
        public convenience init(withBootstrapPort bootstrapPort: MachCore.Mach.BootstrapPort) throws
        {
            var mainPort: mach_port_t = 0
            if #available(macOS 12, *) {
                try Mach.call(IOMainPort(bootstrapPort.name, &mainPort))
            } else {
                try Mach.call(IOMasterPort(bootstrapPort.name, &mainPort))
            }
            self.init(named: mainPort)
        }

        /// Initializes a main port for IOKit.
        public convenience init() {
            if #available(macOS 12, *) {
                self.init(named: kIOMainPortDefault)
            } else {
                self.init(named: kIOMasterPortDefault)
            }
        }
    }

    /// A service for IOKit.
    public class IOService: IOObject {
        /// Gets a service matching the given dictionary.
        public static func getMatchingService(
            usingMainPort mainPort: IOKitMainPort = .init(),
            matching: CFDictionary
        ) -> Self? {
            let service = IOServiceGetMatchingService(mainPort.name, matching)
            guard service != IO_OBJECT_NULL else { return nil }
            return self.init(named: service)
        }

        /// Gets an iterator for services matching the given dictionary.
        public static func getMatchingServices(
            usingMainPort mainPort: IOKitMainPort = .init(),
            matching: CFDictionary
        ) -> IOIterator<IOService>? {
            var iterator: io_iterator_t = IO_OBJECT_NULL
            let service = IOServiceGetMatchingServices(mainPort.name, matching, &iterator)
            guard service != IO_OBJECT_NULL else { return nil }
            return IOIterator(named: iterator)
        }

        /// Returns if the service matches the given dictionary.
        public func matchPropertyTable(matching: CFDictionary) throws -> Bool {
            var result: boolean_t = 0
            try Mach.call(IOServiceMatchPropertyTable(self.name, matching, &result))
            return result != 0
        }

        /// Adds a notification for the service.
        @available(*, deprecated)
        public func addNotification(
            usingMainPort mainPort: IOKitMainPort = .init(),
            notificationType: String,
            matching: CFDictionary,
            wakePort: MachCore.Mach.Port,
            reference: UnsafeMutableRawPointer
        ) throws -> IOIterator<IOObject> {
            var iterator: io_iterator_t = IO_OBJECT_NULL
            try Mach.call(
                IOServiceAddNotification(
                    mainPort.name,
                    String(notificationType.prefix(MemoryLayout<io_name_t>.size)),
                    matching,
                    wakePort.name,
                    UInt(bitPattern: reference),
                    &iterator
                )
            )
            return IOIterator(named: iterator)
        }

        /// Adds a matching notification for the service.
        public func addMatchingNotification(
            notifyPort: IONotificationPort,
            notificationType: String,
            matching: CFDictionary,
            callback: IOServiceMatchingCallback,
            refCon: UnsafeMutableRawPointer
        ) throws -> IOIterator<IOObject> {
            var iterator: io_iterator_t = IO_OBJECT_NULL
            try Mach.call(
                IOServiceAddMatchingNotification(
                    notifyPort.rawValue,
                    String(notificationType.prefix(MemoryLayout<io_name_t>.size)),
                    matching,
                    callback,
                    refCon,
                    &iterator
                )
            )
            return IOIterator(named: iterator)
        }

        /// Adds an interest notification for the service.
        public func addInterestNotification(
            notifyPort: IONotificationPort,
            notificationType: String,
            callback: IOServiceInterestCallback,
            refCon: UnsafeMutableRawPointer
        ) throws -> IOIterator<IOObject> {
            var iterator: io_iterator_t = IO_OBJECT_NULL
            try Mach.call(
                IOServiceAddInterestNotification(
                    notifyPort.rawValue,
                    self.name,
                    String(notificationType.prefix(MemoryLayout<io_name_t>.size)),
                    callback,
                    refCon,
                    &iterator
                )
            )
            return IOIterator(named: iterator)
        }

        /// Returns a matching dictionary to match against a IOService class name.
        public static func matching(_ name: String) -> CFMutableDictionary {
            return IOServiceMatching(name)
        }

        /// Returns a matching dictionary to match against a IOService name.
        public static func nameMatching(_ name: String) -> CFMutableDictionary {
            return IOServiceNameMatching(name)
        }

        /// The busy state of the service.
        public var busyState: UInt32 {
            get throws {
                var state: UInt32 = 0
                try Mach.call(IOServiceGetBusyState(self.name, &state))
                return state
            }
        }

        /// Waits for the service to not be busy, for a maximum of the given time.
        public func waitQuiet(_ waitTime: consuming mach_timespec_t) throws {
            try Mach.call(IOServiceWaitQuiet(self.name, &waitTime))
        }

        /// Options for authorizing an IOKit service.
        public struct IOServiceAuthorizeOptions: OptionSet, Sendable, ExpressibleByIntegerLiteral {
            /// The raw value of the options.
            public let rawValue: IOOptionBits

            /// Represents the raw options value.
            public init(rawValue: IOOptionBits) {
                self.rawValue = rawValue
            }

            /// Represents the integer literal options value.
            public init(integerLiteral value: IOOptionBits) {
                self.rawValue = value
            }

            /// Interaction is allowed.
            public static let interactionAllowed =
                IOServiceAuthorizeOptions(rawValue: IOOptionBits(kIOServiceInteractionAllowed))
        }

        /// Authorizes the service with the given options.
        public func authorize(options: IOServiceAuthorizeOptions) throws {
            try Mach.call(IOServiceAuthorize(self.name, options.rawValue))
        }

        /// Opens the service as a file descriptor with the given options.
        @available(macOS 11.0, *)
        public func openAsFileDescriptor(options: FileDescriptor.OpenOptions) throws
            -> FileDescriptor
        {
            return FileDescriptor(
                rawValue: try BSDCore.BSD.call(
                    IOServiceOpenAsFileDescriptor(self.name, options.rawValue)
                )
            )
        }

        /// Opens the service as a file descriptor with the given options.
        public func openAsFileDescriptor(options: Int32) throws -> Int32 {
            try BSDCore.BSD.call(IOServiceOpenAsFileDescriptor(self.name, options))
        }

        /// Opens the service with the given owning task and type.
        public func open(
            withOwningTask owningTask: MachCore.Mach.Task = .current,
            type: UInt32
        ) throws -> IOConnect {
            var connect: io_connect_t = IO_OBJECT_NULL
            try Mach.call(IOServiceOpen(self.name, owningTask.name, type, &connect))
            return IOConnect(named: connect)
        }
    }

    /// A notification port for IOKit.
    public class IONotificationPort: RawRepresentable {
        /// The raw reference to the notification port.
        public let rawValue: IONotificationPortRef

        /// Represents a raw reference to a notification port.
        public required init(rawValue: IONotificationPortRef) {
            self.rawValue = rawValue
        }

        /// Creates a new notification port with the given main port.
        init(withMainPort mainPort: IOKitMainPort) throws {
            self.rawValue = IONotificationPortCreate(mainPort.name)
        }

        /// The run loop source for the notification port.
        var runLoopSource: CFRunLoopSource? {
            return IONotificationPortGetRunLoopSource(self.rawValue)?.takeUnretainedValue()
        }

        /// The Mach port for the notification port.
        var machPort: MachCore.Mach.Port {
            return Mach.Port(named: IONotificationPortGetMachPort(self.rawValue))
        }

        /// Configures the notification port as an importance receiver.
        func setImportanceReceiver() throws {
            try Mach.call(IONotificationPortSetImportanceReceiver(self.rawValue))
        }

        /// Sets the dispatch queue for the notification port.
        func setDispatchQueue(_ queue: DispatchQueue) {
            IONotificationPortSetDispatchQueue(self.rawValue, queue)
        }

        deinit {
            IONotificationPortDestroy(self.rawValue)
        }
    }

    /// An iterator of IOKit objects.
    public class IOIterator<ObjectType: IOObject>: IOObject, IteratorProtocol {
        /// Resets the iterator.
        public func reset() {
            IOIteratorReset(self.name)
        }

        /// Wether or not the iterator is valid.
        public var isValid: Bool {
            return IOIteratorIsValid(self.name) != 0
        }

        /// Gets the next object in the iterator.
        public func next() -> ObjectType? {
            let service = IOIteratorNext(self.name)
            guard service != IO_OBJECT_NULL else { return nil }
            return ObjectType(named: service)
        }

    }

    /// A connection to an IOKit service.
    public class IOConnect: IOObject {
        /// The service associated with the connection.
        public var service: IOService {
            get throws {
                var service: io_service_t = IO_OBJECT_NULL
                try Mach.call(IOConnectGetService(self.name, &service))
                return IOService(named: service)
            }
        }

        /// Sets the notification port for the connection with the given type and reference.
        public func setNotificationPort(
            _ port: MachCore.Mach.Port,
            forType type: UInt32,
            withReference reference: UnsafeMutableRawPointer? = nil,
        ) throws {
            try Mach.call(
                IOConnectSetNotificationPort(
                    self.name,
                    type,
                    port.name,
                    UInt(bitPattern: reference),
                )
            )
        }

        /// Maps memory of the given type into the given task, at the given buffer, with the given options.
        public func mapMemory(
            ofType type: UInt32,
            intoTask task: MachCore.Mach.Task = .current,
            atBuffer buffer: UnsafeMutableRawBufferPointer,
            withOptions options: IOOptionBits = 0,
        ) throws {
            var memory = mach_vm_address_t(UInt(bitPattern: buffer.baseAddress))
            var size = mach_vm_size_t(buffer.count)
            try Mach.call(
                IOConnectMapMemory(
                    self.name,
                    type,
                    task.name,
                    &memory,
                    &size,
                    options
                )
            )
        }

        /// Unmaps previously mapped memory of the given type from the given task at the given address.
        public func unmapMemory(
            ofType type: UInt32,
            fromTask task: MachCore.Mach.Task = .current,
            atAddress address: UnsafeMutableRawPointer,
        ) throws {
            try Mach.call(
                IOConnectUnmapMemory(
                    self.name,
                    type,
                    task.name,
                    mach_vm_address_t(UInt(bitPattern: address)),
                )
            )
        }

        /// Sets properties for the connection.
        public func setCFProperties(_ properties: CFTypeRef) throws {
            try Mach.call(IOConnectSetCFProperties(self.name, properties))
        }

        /// Sets a property for the connection with the given name.
        public func setCFProperty(withName name: CFString, to value: CFTypeRef) throws {
            try Mach.call(IOConnectSetCFProperty(self.name, name, value))
        }

        /// An set of operands representing either the input or output of a method.
        public struct IOConnectMethodOperands {
            let scalars: [UInt64]?
            let structure: UnsafeRawBufferPointer?
            public init(
                scalars: [UInt64]? = nil,
                structure: UnsafeRawBufferPointer? = nil
            ) {
                self.scalars = scalars
                self.structure = structure
            }
        }

        /// Calls a method on the connection with the given selector and operands.
        public func callMethod(
            selector: UInt32,
            operands: IOConnectMethodOperands = .init(),
            expectedOutputScalarsCount: UInt32 = 0,
            expectedOutputStructureSize: Int = 0
        ) throws -> IOConnectMethodOperands {
            let input = operands
            let outputScalarsPointer: UnsafeMutablePointer<UInt64>? = nil
            let outputStructurePointer: UnsafeMutableRawPointer? = nil
            // For methods with fixed output operand counts/sizes, IOKit will check if the
            //  values we passed in match those fixed values, so we need to pass those in.
            var outputScalarsCount: UInt32 = expectedOutputScalarsCount
            var outputStructureSize = expectedOutputStructureSize
            try Mach.call(
                IOConnectCallMethod(
                    self.name,
                    selector,
                    input.scalars,
                    UInt32(input.scalars?.count ?? 0),
                    input.structure?.baseAddress,
                    input.structure?.count ?? 0,
                    outputScalarsPointer,
                    &outputScalarsCount,
                    outputStructurePointer,
                    &outputStructureSize
                )
            )
            return IOConnectMethodOperands(
                scalars: outputScalarsPointer.map {
                    Array(UnsafeBufferPointer(start: $0, count: Int(outputScalarsCount)))
                },
                structure: outputStructurePointer.map {
                    UnsafeRawBufferPointer(start: $0, count: outputStructureSize)
                }
            )
        }

        /// Calls an an async method on the connection with the given
        ///     selector, wake port, references, and operands.
        public func callAsyncMethod(
            selector: UInt32,
            wakePort: MachCore.Mach.Port,
            references: [UnsafeMutableRawPointer?] = [],
            operands: IOConnectMethodOperands = .init(),
            expectedOutputScalarsCount: UInt32 = 0,
            expectedOutputStructureSize: Int = 0
        ) throws -> IOConnectMethodOperands {
            let input = operands
            let outputScalarsPointer: UnsafeMutablePointer<UInt64>? = nil
            let outputStructurePointer: UnsafeMutableRawPointer? = nil
            // For methods with fixed output operand counts/sizes, IOKit will check if the
            //  values we passed in match those fixed values, so we need to pass those in.
            var outputScalarsCount: UInt32 = expectedOutputScalarsCount
            var outputStructureSize = expectedOutputStructureSize
            var referenceArgs = references.map { UInt64(UInt(bitPattern: $0)) }
            try Mach.call(
                IOConnectCallAsyncMethod(
                    self.name,
                    selector,
                    wakePort.name,
                    &referenceArgs,
                    UInt32(referenceArgs.count),
                    input.scalars,
                    UInt32(input.scalars?.count ?? 0),
                    input.structure?.baseAddress,
                    input.structure?.count ?? 0,
                    outputScalarsPointer,
                    &outputScalarsCount,
                    outputStructurePointer,
                    &outputStructureSize
                )
            )
            return IOConnectMethodOperands(
                scalars: outputScalarsPointer.map {
                    Array(UnsafeBufferPointer(start: $0, count: Int(outputScalarsCount)))
                },
                structure: outputStructurePointer.map {
                    UnsafeRawBufferPointer(start: $0, count: outputStructureSize)
                }
            )
        }

        /// Performs a trap on the connection with the given index and arguments (expressed as pointers).
        /// - Important: The number of arguments must be between 0 and 6.
        public func trap(
            index: UInt32,
            pointers: [UnsafeMutableRawPointer?] = [],
        ) throws {
            let pointerArgs = pointers.map { UInt(bitPattern: $0) }
            switch pointers.count {
            case 0:
                try Mach.call(
                    IOConnectTrap0(
                        self.name,
                        index
                    )
                )
            case 1:
                try Mach.call(
                    IOConnectTrap1(
                        self.name,
                        index,
                        pointerArgs[0])
                )
            case 2:
                try Mach.call(
                    IOConnectTrap2(
                        self.name,
                        index,
                        pointerArgs[0],
                        pointerArgs[1])
                )
            case 3:
                try Mach.call(
                    IOConnectTrap3(
                        self.name,
                        index,
                        pointerArgs[0],
                        pointerArgs[1],
                        pointerArgs[2]
                    )
                )
            case 4:
                try Mach.call(
                    IOConnectTrap4(
                        self.name,
                        index,
                        pointerArgs[0],
                        pointerArgs[1],
                        pointerArgs[2],
                        pointerArgs[3]
                    )
                )
            case 5:
                try Mach.call(
                    IOConnectTrap5(
                        self.name,
                        index,
                        pointerArgs[0],
                        pointerArgs[1],
                        pointerArgs[2],
                        pointerArgs[3],
                        pointerArgs[4]
                    )
                )
            case 6:
                try Mach.call(
                    IOConnectTrap6(
                        self.name,
                        index,
                        pointerArgs[0],
                        pointerArgs[1],
                        pointerArgs[2],
                        pointerArgs[3],
                        pointerArgs[4],
                        pointerArgs[5]
                    )
                )
            default:
                throw MachError(.invalidArgument)
            }
        }

        /// Informs the connection of a second connection.
        public func addClient(_ client: IOConnect) throws {
            try Mach.call(IOConnectAddClient(self.name, client.name))
        }

        deinit {
            IOServiceClose(self.name)
        }
    }

    /// A registry entry for IOKit.
    public class IORegistryEntry: IOObject {
        /// Gets the root registry entry using the given main port.
        public static func getRootEntry(
            usingMainPort mainPort: IOKitMainPort = .init()
        ) -> Self? {
            let entry = IORegistryGetRootEntry(mainPort.name)
            guard entry != IO_OBJECT_NULL else { return nil }
            return self.init(named: entry)
        }

        /// Gets the registry entry with the given path using the given main port.
        public convenience init?(
            fromPath path: String,
            usingMainPort mainPort: IOKitMainPort = .init()
        ) {
            let entry =
                path.count <= MemoryLayout<io_string_t>.size
                ? IORegistryEntryFromPath(
                    mainPort.name,
                    String(path.prefix(MemoryLayout<io_string_t>.size))
                )
                : IORegistryEntryCopyFromPath(
                    mainPort.name,
                    path as CFString
                )
            guard entry != IO_OBJECT_NULL else { return nil }
            self.init(named: entry)
        }

        /// Gets the name of the entry, optionally within the given plane.
        public func getName(inPlane plane: String? = nil) throws -> String {
            let namePointer =
                UnsafeMutablePointer<CChar>.allocate(capacity: MemoryLayout<io_name_t>.size)
            defer { namePointer.deallocate() }
            if let planeToSearch = plane {
                try Mach.call(
                    IORegistryEntryGetNameInPlane(
                        self.name,
                        String(planeToSearch.prefix(MemoryLayout<io_name_t>.size)),
                        namePointer
                    )
                )
            } else {
                try Mach.call(IORegistryEntryGetName(self.name, namePointer))
            }
            let name = String(cString: namePointer)
            return name
        }

        /// Gets the location of the entry within the given plane.
        public func getLocation(inPlane plane: String) throws -> String {
            let locationPointer =
                UnsafeMutablePointer<CChar>.allocate(capacity: MemoryLayout<io_name_t>.size)
            defer { locationPointer.deallocate() }
            try Mach.call(
                IORegistryEntryGetLocationInPlane(
                    self.name,
                    String(plane.prefix(MemoryLayout<io_name_t>.size)),
                    locationPointer
                )
            )
            let location = String(cString: locationPointer)
            return location
        }

        /// Gets the path of the entry within the given plane.
        /// - Warning: This method will throw an error if the path is too long.
        public func getPath(inPlane plane: String) throws -> String {
            let pathPointer =
                UnsafeMutablePointer<CChar>.allocate(capacity: MemoryLayout<io_string_t>.size)
            defer { pathPointer.deallocate() }
            try Mach.call(
                IORegistryEntryGetPath(
                    self.name,
                    String(plane.prefix(MemoryLayout<io_name_t>.size)),
                    pathPointer
                )
            )
            let path = String(cString: pathPointer)
            return path
        }

        /// Gets the path of the entry within the given plane.
        /// - Warning: This method will return nil if there was any error.
        public func getPath(inPlane plane: String) -> String? {
            return IORegistryEntryCopyPath(
                self.name,
                String(plane.prefix(MemoryLayout<io_name_t>.size)),
            )?.takeRetainedValue() as String?
        }

        /// The registry entry ID of the entry.
        public var registryEntryID: UInt64 {
            get throws {
                var entryID: UInt64 = 0
                try Mach.call(IORegistryEntryGetRegistryEntryID(self.name, &entryID))
                return entryID
            }
        }

        /// Returns a matching dictionary to match against a registry entry ID.
        public static func registryEntryIDMatching(_ registryEntryID: UInt64)
            -> CFMutableDictionary
        {
            return IORegistryEntryIDMatching(registryEntryID)
        }

        /// Creates a dictionary representing the properties of the entry.
        public func createCFProperties(
            withAllocator allocator: CFAllocator? = kCFAllocatorDefault,
            options: IOOptionBits = 0
        ) throws -> CFMutableDictionary? {
            let propertiesPointer =
                UnsafeMutablePointer<Unmanaged<CFMutableDictionary>?>.allocate(capacity: 1)
            defer { propertiesPointer.deallocate() }
            try Mach.call(
                IORegistryEntryCreateCFProperties(
                    self.name,
                    propertiesPointer,
                    allocator,
                    options
                )
            )
            guard let unmanagedProperties = propertiesPointer.pointee
            else { return nil }
            return unmanagedProperties.takeUnretainedValue()
        }

        /// Creates a representation of the entry's property with
        ///     the given key, using the given allocator.
        public func createCFProperty(
            withKey key: CFString,
            allocator: CFAllocator? = kCFAllocatorDefault,
            options: IOOptionBits = 0
        ) throws -> CFTypeRef? {
            let unmanagedProperty =
                IORegistryEntryCreateCFProperty(
                    self.name,
                    key,
                    allocator,
                    options,
                )
            return unmanagedProperty?.takeUnretainedValue()
        }

        /// Searches for a property of the entry in the given plane, with
        ///    the given key, using the given allocator and options.
        public func searchCFProperty(
            inPlane plane: String,
            withKey key: CFString,
            allocator: CFAllocator? = kCFAllocatorDefault,
            options: IORegistryIterationOptions
        ) throws -> CFTypeRef? {
            return IORegistryEntrySearchCFProperty(
                self.name,
                String(plane.prefix(MemoryLayout<io_name_t>.size)),
                key,
                allocator,
                options.rawValue
            )
        }

        /// Gets the raw bytes of the entry property with the given name.
        public func getProperty(withName name: String) throws -> UnsafeBufferPointer<CChar> {
            let outputBuffer = UnsafeMutablePointer<CChar>.allocate(
                capacity: MemoryLayout<io_struct_inband_t>.size
            )
            defer { outputBuffer.deallocate() }
            var bufferSize = UInt32(MemoryLayout<io_struct_inband_t>.size)
            try Mach.call(
                IORegistryEntryGetProperty(
                    self.name,
                    String(name.prefix(MemoryLayout<io_name_t>.size)),
                    outputBuffer,
                    &bufferSize
                )
            )
            let mutableReturnedBuffer =
                UnsafeMutableBufferPointer<CChar>.allocate(capacity: Int(bufferSize))
            mutableReturnedBuffer.baseAddress!
                .initialize(from: outputBuffer, count: Int(bufferSize))
            return UnsafeBufferPointer(mutableReturnedBuffer)
        }

        /// Sets the property of the entry.
        public func setCFProperties(
            _ properties: CFTypeRef,
        ) throws {
            try Mach.call(IORegistryEntrySetCFProperties(self.name, properties))
        }

        /// Sets the property of the entry with the given name.
        public func setCFProperty(
            withName name: CFString,
            to value: CFTypeRef
        ) throws {
            try Mach.call(IORegistryEntrySetCFProperty(self.name, name, value))
        }

        /// Gets an iterator for the children of the entry in the given plane.
        public func getChildIterator(inPlane plane: String) throws
            -> IORegistryIterator?
        {
            var iterator: io_iterator_t = IO_OBJECT_NULL
            try Mach.call(
                IORegistryEntryGetChildIterator(
                    self.name,
                    String(plane.prefix(MemoryLayout<io_name_t>.size)),
                    &iterator
                )
            )
            guard iterator != IO_OBJECT_NULL else { return nil }
            return IORegistryIterator(named: iterator)
        }

        /// Gets the first child entry of the entry in the given plane.
        public func getChildEntry(inPlane plane: String) throws
            -> IORegistryEntry?
        {
            var entry: io_service_t = IO_OBJECT_NULL
            try Mach.call(
                IORegistryEntryGetChildEntry(
                    self.name,
                    String(plane.prefix(MemoryLayout<io_name_t>.size)),
                    &entry
                )
            )
            guard entry != IO_OBJECT_NULL else { return nil }
            return IORegistryEntry(named: entry)
        }

        /// Gets an iterator for the parents of the entry in the given plane.
        public func getParentIterator(inPlane plane: String) throws
            -> IORegistryIterator?
        {
            var iterator: io_iterator_t = IO_OBJECT_NULL
            try Mach.call(
                IORegistryEntryGetParentIterator(
                    self.name,
                    String(plane.prefix(MemoryLayout<io_name_t>.size)),
                    &iterator
                )
            )
            guard iterator != IO_OBJECT_NULL else { return nil }
            return IORegistryIterator(named: iterator)
        }

        /// Gets the first parent entry of the entry in the given plane.
        public func getParentEntry(inPlane plane: String) throws
            -> IORegistryEntry?
        {
            var entry: io_service_t = IO_OBJECT_NULL
            try Mach.call(
                IORegistryEntryGetParentEntry(
                    self.name,
                    String(plane.prefix(MemoryLayout<io_name_t>.size)),
                    &entry
                )
            )
            guard entry != IO_OBJECT_NULL else { return nil }
            return IORegistryEntry(named: entry)
        }

        /// Determines if the entry is in the given plane.
        public func isInPlane(_ plane: String) throws -> Bool {
            return IORegistryEntryInPlane(
                self.name,
                String(plane.prefix(MemoryLayout<io_name_t>.size)),
            ) != 0
        }
    }

    /// Options for iteration in the IOKit registry.
    public struct IORegistryIterationOptions: OptionSet, Sendable, ExpressibleByIntegerLiteral {
        /// The raw value of the options.
        public let rawValue: IOOptionBits

        /// Represents the raw options value.
        public init(rawValue: IOOptionBits) {
            self.rawValue = rawValue
        }

        /// Represents the integer literal options value.
        public init(integerLiteral value: IOOptionBits) {
            self.rawValue = value
        }

        /// Automatically recurse into and iterate over children.
        public static let iterateRecursively =
            IORegistryIterationOptions(rawValue: IOOptionBits(kIORegistryIterateRecursively))

        /// Iterate over the parents of each entry.
        public static let iterateParents =
            IORegistryIterationOptions(rawValue: IOOptionBits(kIORegistryIterateParents))
    }

    /// An iterator for registry entries in IOKit.
    public class IORegistryIterator: IOIterator<IORegistryEntry> {
        /// Initializes a new iterator with the given main port, plane, and options.
        public convenience init(
            withMainPort mainPort: IOKitMainPort = .init(),
            plane: String,
            options: IORegistryIterationOptions
        ) throws {
            var iterator: io_iterator_t = IO_OBJECT_NULL
            try Mach.call(
                IORegistryCreateIterator(
                    mainPort.name,
                    String(plane.prefix(MemoryLayout<io_name_t>.size)),
                    options.rawValue,
                    &iterator
                )
            )
            self.init(named: iterator)
        }

        /// Initializes a new iterator with the given entry, plane, and options.
        public convenience init(
            withEntry entry: IORegistryEntry,
            plane: String,
            options: IORegistryIterationOptions
        ) throws {
            var iterator: io_iterator_t = IO_OBJECT_NULL
            try Mach.call(
                IORegistryEntryCreateIterator(
                    entry.name,
                    String(plane.prefix(MemoryLayout<io_name_t>.size)),
                    options.rawValue,
                    &iterator
                )
            )
            self.init(named: iterator)
        }

        /// Enters into the current entry of the iterator to iterate over its children.
        public func enterEntry() throws {
            try Mach.call(IORegistryIteratorEnterEntry(self.name))
        }

        /// Exits the current entry of the iterator to iterate over its parent and that parents siblings.
        public func exitEntry() throws {
            try Mach.call(IORegistryIteratorExitEntry(self.name))
        }
    }
}
